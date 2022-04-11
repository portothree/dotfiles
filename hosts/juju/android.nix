{
  # udev rule for Xiaomi Inc. Mi/Redmi series (MTP + ADB)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="ff08", MODE="0666", GROUP="plugdev"
  '';
}
