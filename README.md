🗃️ Log Archive Script

A lightweight and user-friendly Bash script to archive log files into timestamped `.tar.gz` archives. It includes checks for directory validity, readable access, and logs each operation for audit or reference.

---

🚀 Features

- ✅ Compresses logs into `.tar.gz` archives with timestamped filenames.
- 🧾 Creates a structured archive log file for auditing.
- 📂 Handles empty directories with a user prompt.
- 📊 Displays archive summary including size and file count.
- 🎨 Colored output for better readability.
- 🔒 Includes safety checks for directory existence and permissions.

---

🛠️ Usage


./log_archive.sh <log-directory>


Example:


./log_archive.sh /var/log


---

📌 Requirements

* Bash (v4+ recommended)
* Standard Unix utilities: `tar`, `du`, `realpath`

---

📁 Output

* Archive is saved in a local `./log_archives/` directory.
* Filename format: `logs_archive_YYYYMMDD_HHMMSS.tar.gz`
* Archive log saved at: `./log_archives/archive_log.txt`

---

📒 Archive Log Example


===========================================
Archive Date: 2025-05-28 14:23:45
Source Directory: /var/log
Archive File: logs_archive_20250528_142345.tar.gz
Archive Size: 5.2M
Archive Location: /path/to/log_archives/logs_archive_20250528_142345.tar.gz
Files Archived:
log1.txt
log2.log
...
... and 17 more files
===========================================


---

⚠️ Optional Cleanup

To optionally remove the original log files after archiving, uncomment the block near the end of the script:


rm -rf "$LOG_DIRECTORY"/*


---

🧑‍💻 Author

Naveen Kalapala
Feel free to reach out or contribute!




