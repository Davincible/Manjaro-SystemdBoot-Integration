# Manjaro better systemd-boot integration
A more robust integration with systemd-boot, allowing for installation in `/boot`, `/efi` or `/boot/efi`

The default hooks of Manjaro are adament about installing all kernel images in `/boot`, but when your bootloader is installed in another location this gives rise to issues, as the boot entries then can't access the images.

To resolve this the default hooks have been amended to to adhere to [Boot Loader Specification](https://systemd.io/BOOT_LOADER_SPECIFICATION/) created by Systemd, which specifies that in order to create a healthy ecosystem for multiboot, it is best to install kernel images under <bootloader dir>/EFI/<distro>-<UUID>. This has been implemented in the hooks and their respective scripts in this repo. 
  
Futhermore, the sdboot-manage utility was also not created to deal with this scenario, so an amended one has been added here.
