from pathlib import Path
import logging

 # resolve issue with the file path as fastapi is throwing an error 
# this makes the file path absolute to the project dir
BASE_DIR = Path(__file__).resolve().parent.parent.parent
log_dir = BASE_DIR / "logs"
log_dir.mkdir(exist_ok=True)

def get_logger(name: str=__name__) -> logging.Logger | None:
    """
    used to create custom logs for each module 


    """

    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    # prevent duplicate handlers
    if not logger.handlers:
        log_file = log_dir / f"{name}.log"

        handler = logging.FileHandler(log_file, mode="w")
        formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s - %(lineno)d")
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.propagate = False

        return logger
    
    # configure a shared log which logs the program as a whole
# https://medium.com/@shrimantshubham/basic-example-of-log-into-a-single-log-file-from-several-python-modules-090e57ce8f50
shared_logger = logging.getLogger(__name__)
shared_logger.setLevel(logging.DEBUG)

# prevent duplicate handlers
if not shared_logger.handlers:
    shared_log_file = log_dir / "shared_log.log"
    handler = logging.FileHandler(shared_log_file, mode="w")
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s - %(lineno)d")
    handler.setFormatter(formatter)
    shared_logger.addHandler(handler)
    shared_logger.propagate = False