import json
import shlex
import subprocess
import time
from glob import glob

import schedule
from loguru import logger


def main():
    source_path = '/home/pi/pi-timolo/media/motion'
    imgs = glob(f'{source_path}/*.jpg')
    if len(imgs) > 0:
        logger.info(f'Moving {len(imgs)} image.')
        logger.info(f'Will transfer: {json.dumps(imgs, indent=4)}')
        cmd = f'rclone move {source_path} birdcam: -P --stats-one-line'
        p = subprocess.run(shlex.split(cmd),
                           shell=False,
                           check=True,
                           capture_output=True,
                           text=True)
        logger.info(f'Process exit code: {p.returncode}')
        logger.debug(f'stdout: {p.stdout}')
        logger.debug(f'stderr: {p.stderr}')


if __name__ == '__main__':
    logger.add('auto_rclone_upload.log')
    schedule.every().hour.do(main)
    while True:
        schedule.run_pending()
        time.sleep(1)
