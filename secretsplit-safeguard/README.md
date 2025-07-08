# shamir_secret_plg_example

This project is to safeguard the Secret Split application. If anything happens to the app, or the 
website https://secretsplit.io then the owner of the key can recover the secret. There is a hic 
though, if the encrypted file is stored on the Secret Split server an it is no longer available then
the secret is gone. We are looking for people to mirror the files. If you are interested please
contact __secretsplit at secretsplit dot io__

## Algorithm

| Version | Share Algorithm | Encryption Algorithm                                   |
|---------|------------------|--------------------------------------------------------|
| 1       | ShamirClaude01   | AES-128 encryption in CBC mode without MAC and prepends the IV |

## File Structure

| Version | Header                        | 
|---------|-------------------------------|
| 1       | NO_EXECUTABLE + IV (16 bytes) |


## The Basic

You can compile this project or you can take the executable for your os from  
https://github.com/theyoz/shamir_flutter_plugin/releases

There are 3 executable

| name               | OS      | 
|--------------------|---------|
| shamir_linux       | Linux   |
| shamir_macos       | Mac     |
| shamir_windows.exe | Windows |

We'll assume that we are using __shamir_linux__ for the rest of the doc

## Retrieving the encrypted file from the cloud

You need to read on of the QR or file.txt created by Secret Split

### text file
if it is a text file just open it

```text
filename=Secret Split qna for apply.pdf
ID=8e82a04b-14c7-4641-af6a-2c3983435a2f
min_shares=5
Version=1
Share=0a637a0659fb125e97ac3dd3f4654bd9ad
```
the ID is __8e82a04b-14c7-4641-af6a-2c3983435a2f__

### QR Code
If it is a QR code then use the command

```shell
  ./shamir_linux read_qr <fullpath>/lxs_share_9_of_10.txt.png
```

you will then have the same as the __text file__ section above

Then let's say the id is __18853dee-920c-450b-8f00-b575a1da372e__

```shell
wget https://api.secretsplit.io/v1/vault/storage/18853dee-920c-450b-8f00-b575a1da372e
```

## Reconstruct the secret

To reconstruct the secret you need the files and all the part and run the command line

```shell
./shamir_linux reconstruct <fullpath>/18853dee-920c-450b-8f00-b575a1da372e <fullpath>/share1.txt <fullpath>/share2.txt 
```

If successful the secret file path will be shown on the console

```text
Secret reconstructed and written to File: '<FULLPATH>/<ORIGINAL_SECRET_FILE>'
```