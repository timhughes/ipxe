# Customizing the Boot Menu

The generated iPXE menu includes commented-out customization options that you can enable by editing the `elfshoe.ipxe` file.

## Visual Customization Options

The generated iPXE menu automatically includes a background image and provides additional customization options:

```ipxe
#!ipxe
dhcp

# Visual customization
# Background image
imgfetch https://timhughes.github.io/ipxe/images/background.png || echo Failed to fetch background
imgdraw background.png || echo Failed to draw background

# Customize colors (optional - uncomment to enable):
# cpair --foreground 0x00cc00 --background 0x000000 0  # Green on black
# cpair --foreground 0xffffff --background 0x0066cc 1  # White on blue (selected)
# cpair --foreground 0xcccccc --background 0x000000 2  # Gray on black (normal text)

# Set console resolution (optional - uncomment to enable):
# console --x 1024 --y 768
```

!!! info "Background Image"
    The menu includes a default background image hosted on GitHub Pages. This requires iPXE to be built with `IMAGE_PNG` support. If your iPXE build doesn't support images, the menu will still work - it just won't display the background.

## How to Enable Customizations

### 1. Clone the Repository

```bash
git clone https://github.com/timhughes/ipxe.git
cd ipxe
```

### 2. Edit elfshoe.ipxe

Open `docs/elfshoe.ipxe` and uncomment the options you want:

!!! example "Example: Enable Custom Colors"

    ```ipxe
    #!ipxe
    dhcp

    # Visual customization
    cpair --foreground 0x00cc00 --background 0x000000 0  # Green on black
    cpair --foreground 0xffffff --background 0x0066cc 1  # White on blue (selected)

    :start
    menu Network Boot Menu
    ...
    ```

### 3. Commit and Push

```bash
git add docs/elfshoe.ipxe
git commit -m "chore: enable custom colors"
git push
```

The GitHub Actions workflow will automatically rebuild and deploy your customized menu.

## Customization Options Explained

### Color Pairs (`cpair`)

iPXE uses color pairs to define text appearance:

- **Pair 0**: Normal menu items
- **Pair 1**: Selected/highlighted items  
- **Pair 2**: Additional text elements

**Color format**: `0xRRGGBB` (hexadecimal RGB)

!!! tip "Common Color Schemes"

    **Matrix Green:**
    ```ipxe
    cpair --foreground 0x00ff00 --background 0x000000 0
    cpair --foreground 0x000000 --background 0x00ff00 1
    ```

    **Corporate Blue:**
    ```ipxe
    cpair --foreground 0xffffff --background 0x003366 0
    cpair --foreground 0xffffff --background 0x0066cc 1
    ```

    **Dark Mode:**
    ```ipxe
    cpair --foreground 0xcccccc --background 0x1a1a1a 0
    cpair --foreground 0xffffff --background 0x333333 1
    ```

### Console Resolution

Set a custom console resolution for your boot menu:

```ipxe
console --x 1024 --y 768
```

Common resolutions:
- `800x600` - Standard
- `1024x768` - XGA
- `1280x1024` - SXGA
- `1920x1080` - Full HD

### Background Images

Display PNG images as backgrounds:

```ipxe
imgfetch http://yourserver.com/background.png
imgdraw background.png
```

!!! warning "Requirements"
    - Image must be PNG format
    - iPXE must be compiled with `IMAGE_PNG` support
    - Keep images small (recommended < 100KB)
    - Use appropriate resolution for your target display

## Advanced: Custom Per-Distribution Logos

For per-distribution customization (like showing Fedora logo in Fedora submenu), we're tracking this feature request in [elfshoe issue #2](https://github.com/timhughes/elfshoe/issues/2).

**Current workaround**: Manually edit the generated file and add `imgfetch`/`imgdraw` commands before each submenu label (e.g., before `:fedora_menu`).

## Hosting Custom Assets

If you want to host background images or logos:

### Option 1: Add to GitHub Pages

```bash
# Add images to docs directory
mkdir -p docs/images
cp background.png docs/images/

# Reference in elfshoe.ipxe
imgfetch https://timhughes.github.io/ipxe/images/background.png
```

### Option 2: Use External Hosting

Host images on your own server and reference them:

```ipxe
imgfetch http://yourserver.com/ipxe/background.png
imgdraw background.png
```

## Testing Your Customizations

Before deploying, test in a VM:

1. Set up PXE boot in a virtual machine
2. Point it to your test menu
3. Verify colors and images display correctly
4. Test on both BIOS and UEFI boot modes

## Troubleshooting

### Colors not appearing
- Ensure your terminal/console supports colors
- Some hardware may have limited color support

### Background image not loading
- Check that iPXE was built with `IMAGE_PNG` support
- Verify the image URL is accessible from the boot network
- Try a smaller image file
- Check image format is PNG (not JPG)

### Console resolution not changing
- Some systems may ignore resolution commands
- Try different resolution values
- Check if your hardware supports the requested resolution

## Future Improvements

We've requested native support for customization in elfshoe. Track progress:

- [Issue #2: Support for custom iPXE preamble commands and distribution logos](https://github.com/timhughes/elfshoe/issues/2)

Once implemented, you'll be able to configure customizations directly in `config.yaml` instead of editing the generated file.
