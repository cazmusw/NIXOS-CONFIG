"""Run the real installer against a temporary /etc and simulated Nix commands."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

INSTALLER = Path(__file__).resolve().parents[1] / 'install.sh'

class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='nixos install test ')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.etc = self.root / 'etc'
        self.etc.mkdir()
        self.target = self.etc / 'nixos'
        self.target.mkdir()
        (self.target / 'old.nix').write_text('old settings')
        self.source = self.root / 'source'
        self.source.mkdir()
        (self.source / 'flake.nix').write_text('{}')
        (self.source / 'flake.lock').write_text('{}')
        (self.source / 'new.nix').write_text('new settings')
        script = INSTALLER.read_text().replace('ETC_DIR=/etc', f'ETC_DIR={shlex_quote(str(self.etc))}').replace('LOCK_FILE=/run/nixos-config-install.lock', f'LOCK_FILE={shlex_quote(str(self.root / "lock"))}')
        (self.source / 'install.sh').write_text(script)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, PATH=str(self.bin)+':'+os.environ['PATH'], TEST_LOG=str(self.root / 'commands'), TMPDIR=str(self.root))
        self.command('id', 'echo 0')
        self.command('chown', 'exit 0')
        self.command('nix', 'printf "build\\n" >> "$TEST_LOG"; exit "${BUILD_FAILURE:-0}"')
        self.command('nixos-rebuild', 'printf "activate\\n" >> "$TEST_LOG"; exit "${ACTIVATION_FAILURE:-0}"')

    def command(self, name, body):
        p = self.bin / name
        p.write_text('#!/usr/bin/env bash\n'+body+'\n')
        p.chmod(0o755)

    def run_install(self, *args, **env):
        return subprocess.run(['bash', str(self.source / 'install.sh'), *args], env=self.env | env, capture_output=True, text=True, timeout=15)

    def test_check_builds_without_changing_etc_or_activating(self):
        result = self.run_install('--check')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.target / 'old.nix').read_text(), 'old settings')
        self.assertEqual((self.root / 'commands').read_text(), 'build\n')
        self.assertEqual(list(self.etc.iterdir()), [self.target])

    def test_success_installs_and_preserves_full_backup(self):
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.target / 'new.nix').read_text(), 'new settings')
        self.assertFalse((self.target / 'old.nix').exists())
        backups = list(self.etc.glob('nixos.backup.*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / 'old.nix').read_text(), 'old settings')
        self.assertEqual((self.root / 'commands').read_text(), 'build\nactivate\n')

    def test_build_failure_keeps_original_and_never_activates(self):
        result = self.run_install(BUILD_FAILURE='7')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.target / 'old.nix').read_text(), 'old settings')
        self.assertEqual(list(self.etc.iterdir()), [self.target])
        self.assertEqual((self.root / 'commands').read_text(), 'build\n')

    def test_activation_failure_restores_original_files(self):
        result = self.run_install(ACTIVATION_FAILURE='4')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.target / 'old.nix').read_text(), 'old settings')
        self.assertFalse((self.target / 'new.nix').exists())
        self.assertIn('--rollback', result.stderr)

    def test_first_install_without_existing_directory(self):
        shutil.rmtree(self.target)
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.target / 'new.nix').read_text(), 'new settings')
        self.assertEqual(list(self.etc.glob('nixos.backup.*')), [])

    def test_first_install_failure_keeps_failed_config_for_diagnosis(self):
        shutil.rmtree(self.target)
        result = self.run_install(ACTIVATION_FAILURE='4')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.exists())
        failed = list(self.etc.glob('nixos.failed.*/config/new.nix'))
        self.assertEqual(len(failed), 1)
        self.assertIn('--rollback', result.stderr)

    def test_missing_lockfile_fails_before_build(self):
        (self.source / 'flake.lock').unlink()
        result = self.run_install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / 'commands').exists())
        self.assertTrue((self.target / 'old.nix').exists())

    def test_symlink_target_is_not_replaced(self):
        real = self.etc / 'real-config'
        self.target.rename(real)
        self.target.symlink_to(real)
        result = self.run_install()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual((real / 'old.nix').read_text(), 'old settings')

    def test_installing_from_etc_itself_keeps_working(self):
        shutil.copytree(self.source, self.target, dirs_exist_ok=True)
        result = subprocess.run(['bash', str(self.target / 'install.sh')], env=self.env, capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.target / 'new.nix').read_text(), 'new settings')

    def test_unknown_option_does_not_mutate_files(self):
        result = self.run_install('--bad-option')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / 'commands').exists())
        self.assertTrue((self.target / 'old.nix').exists())

def shlex_quote(value):
    import shlex
    return shlex.quote(value)

if __name__ == '__main__':
    unittest.main(verbosity=2)
