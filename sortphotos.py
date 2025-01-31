import os
from PIL import Image
from PIL.ExifTags import TAGS
import shutil
import time
from pathlib import Path
import sys

_TAGS_r = dict(((v, k) for k, v in TAGS.items()))
total_files = 0
processed_photos = 0
not_processed_photos = 0


def process_photo(file_path, dest_path):
    global processed_photos, not_processed_photos

    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist")
        not_processed_photos += 1
        return

    file_date = ""
    file_extension = ""

    try:  # Try to get image metadata
        with Image.open(file_path) as im:
            exif_data_PIL = im._getexif()
            # Get exif data, or created/modified date
            if (
                exif_data_PIL is not None
                and exif_data_PIL[_TAGS_r["DateTimeOriginal"]] is not None
                and exif_data_PIL[_TAGS_r["DateTimeOriginal"]] != ""
                and len(exif_data_PIL[_TAGS_r["DateTimeOriginal"]]) > 10
            ):
                file_date = exif_data_PIL[_TAGS_r["DateTimeOriginal"]]
                file_date = file_date.replace(":", "-")
                file_date = file_date.replace(" ", "-")
            else:
                file_date = ""
            file_extension = f".{im.format}"
    except:
        pass
        # print(f"Error occurred processing file {file_path}")

    if (
        file_date == ""
    ):  # Could be an image without metadata, or not even an image at all
        ctime = time.localtime(os.path.getctime(file_path))
        mtime = time.localtime(os.path.getmtime(file_path))
        photo_time = min(ctime, mtime)
        file_date = f"{photo_time.tm_year:04}-{photo_time.tm_mon:02}-{photo_time.tm_mday:02}-{photo_time.tm_hour:02}-{photo_time.tm_min:02}-{photo_time.tm_sec:02}"
        if file_extension == "":
            file_extension = Path(file_path).suffix

    filter_file(file_date, file_path, file_extension, dest_path)


def filter_file(file_date, file_path, file_extension, dest_path):
    global processed_photos, not_processed_photos
    try:
        print(file_date)
        dest_folder = file_date[:7].replace("-", "")
        if not os.path.isdir(os.path.abspath(os.path.join(dest_path, dest_folder))):
            os.mkdir(os.path.abspath(os.path.join(dest_path, dest_folder)))
        new_photo_name = os.path.abspath(
            os.path.join(dest_path, dest_folder, file_date + file_extension)
        )
        duplicate_counter = 1
        if os.path.exists(new_photo_name):
            while os.path.exists(f"{new_photo_name}"):
                duplicate_counter += 1
                new_photo_name = os.path.abspath(
                    os.path.join(
                        dest_path,
                        dest_folder,
                        file_date + "-" + str(duplicate_counter) + file_extension,
                    )
                )
        if os.path.exists(new_photo_name):
            print(f"File {new_photo_name} exists. Aborting...")
            not_processed_photos += 1
            return
        shutil.move(file_path, new_photo_name)
        processed_photos += 1
        print(f"'{file_path}' -> '{new_photo_name}'")
    except:
        print(f"Error occurred processing file {file_path}")


def process_folder(folder_path, dest_path):
    global total_files
    for file in os.listdir(folder_path):
        file_name_in = os.path.abspath(os.path.join(folder_path, file))
        if os.path.isdir(file_name_in):
            process_folder(file_name_in, dest_path)
        else:
            process_photo(file_name_in, dest_path)


def main():
    local_path = sys.argv[1]
    if local_path is None or local_path == "":
        return
    if not os.path.exists(os.path.abspath(local_path)):
        print(f"Error: Path {local_path} doesn't exist")
        return
    dest_path = sys.argv[2]
    if dest_path is None or dest_path == "":
        return
    if not os.path.exists(os.path.abspath(dest_path)):
        os.mkdir(os.path.abspath(dest_path))
    tic = time.perf_counter()
    process_folder(local_path, dest_path)
    print(
        f"Processed {processed_photos}, missed {not_processed_photos}. Total: {processed_photos + not_processed_photos}"
    )
    toc = time.perf_counter()
    print(f"Time used: {toc - tic:0.4f} seconds")


if __name__ == "__main__":
    main()
