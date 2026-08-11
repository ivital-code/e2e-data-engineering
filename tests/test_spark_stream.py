import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import spark_stream


class SparkStreamWindowsHadoopTests(unittest.TestCase):
    def test_ensure_hadoop_winutils_creates_windows_hadoop_home(self):
        original_hadoop_home = os.environ.get("HADOOP_HOME")
        original_hadoop_home_dir = os.environ.get("hadoop.home.dir")

        try:
            os.environ.pop("HADOOP_HOME", None)
            os.environ.pop("hadoop.home.dir", None)

            with tempfile.TemporaryDirectory() as tmp_dir:
                target_dir = Path(tmp_dir) / "hadoop-home"

                with patch.object(spark_stream, "DEFAULT_HADOOP_HOME", str(target_dir)):
                    spark_stream.ensure_hadoop_winutils()

                    self.assertEqual(os.environ["HADOOP_HOME"], str(target_dir))
                    self.assertEqual(os.environ["hadoop.home.dir"], str(target_dir))
                    self.assertTrue((target_dir / "bin" / "winutils.exe").exists())
        finally:
            if original_hadoop_home is not None:
                os.environ["HADOOP_HOME"] = original_hadoop_home
            else:
                os.environ.pop("HADOOP_HOME", None)

            if original_hadoop_home_dir is not None:
                os.environ["hadoop.home.dir"] = original_hadoop_home_dir
            else:
                os.environ.pop("hadoop.home.dir", None)


if __name__ == "__main__":
    unittest.main()
