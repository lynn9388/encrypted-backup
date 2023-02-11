# Encrypted backup

## Introduction

This project is used to encrypt and decrypt files and directories before and after backup. It uses AES-256 encryption and SHA-256 hashing to protect the filename and content of the files.

## Usage

Below are the main commands used to encrypt and decrypt files and directories. You can also check the help of each command in the script.

### Encrypt

```bash
./encrypt.sh [-d path] file1 file2 file3 ...
```

### Decrypt

```bash
./decrypt.sh [-d path] [-filenames] file1 file2 file3 ...
```
