# Arch Linux Audio Packages
## Audio Plugins
There are some nice pre-made package groups for audio plugins. 
```
yay -S lv2-plugins vst-plugins vst3-plugins
```
## Audio Software
Install the audio packages: 
```
yay -S luppp carla yabridge reaper qpwgraph pipecontrol
```
* luppp - Looper software
* carla - VST plugin host for Jack
* yabridge - Windows VST plugin host for Jack
* reaper - DAW for recording/mixing
* qpwgraph - Pipewire graph conneciton, replaces QJackCtl. Instead of actual jack, arch uses Pipewire which emulates jack via the package pipewire-jack.
* pipecontrol - Pipewire settings for sample rate and buffer size, replaces QJackCtl settings.

### PipeControl - Configure Sample Rate and Buffer
Without setting this, Luppp can do some crazy behaviors like tempos that are way faster than the specified BPM and garbled audio.  This is possibly due to the dynamic buffers in pipewire, where it is probably expecting a fixed size from Jack (which pipewire is emulating).  Once I set this, the audio from the Lexicon Lambda sounded flawless.
* Open pipecontrol (menu or CLI)
* Click `Settings` in the top-right.
* Set `Force sample rate` to `44100` (or whatever the desired sample rate is)
* Set `Force buffer size` to `128` or `256` (if 128 has issues) for good latency.
* Click `advanced` in the top-right.
* Click the `Restart` button next to `Session service`

### QPWGraph - Patchbay connections for Pipewire-Jack
This is the main connection graph program that connects Luppp to the audio interface and FX plugin hosts (Calf Jack Host in this example).
* The graph can be saved as a "patchbay" file. I defaulted this to ~/Music/Patchbay/ for all the files.
* The `Activated` button should be enabled. It causes the saved connections to automatically reconnect once the host program/port is available.  It seems to be able to do it on-the-fly, so you could load a connection file and then load the programs and they will connect once available.
* The `Exclusive` button should be enabled. It causes previous connections to be cleared when a new Patchbay file is loaded.  If not enabled, the existing connections will be combined with the load file's connections.

### Luppp Ports Connections in QPWGraph
This was the basic setup I used for testing and some explanations about the patchbay ports.
* The Lambda capture_FL/FR ports -> Luppp master_in_left/right
* Luppp master_left/right -> Lambda playback_FL/FR
* OPTIONAL: Luppp headphone_out_l/r -> playback_FL/FR or preferrable some other output only the performer hears.  This plays the Metronome from Lupp and does NOT have the main loop audio.
* For Sound FX in Luppp:
    * Luppp Send_track_N_l/r -> Calf Studio <effect_name> In #1/2
    * Calf Studio <effect_name> Out #1/2 -> Luppp Return_track_N_l/r
    * Then in Luppp, when playing enable the yellow `FX` button to enable sending through the effect send. Disable the yellow `FX` button to disable the effects send and just play the raw loop sound.

# Reaper UI Scaling for KDE
Reaper seems to ignore the UI scaling for KDE plasma, but it has its own internal UI scaling feature.
* Edit `~/.config/REAPER/reaper.ini`
* In the `[.swell]` section find the line for `ui_scale=1.0` and change it to `ui_scale=1.5` or some other desired scale factor

Sources:
* https://forum.cockos.com/showthread.php?t=213959

# Linux Basic Setup
```
yay -S moreutils rustdesk-bin anydesk-bin onlyoffice-bin florence
```
* moreutils - package to allow the update.sh script in this folder to do the orphan package cleanup with no errors.
* rustdesk-bin - Remote access/support software, opensource and allows self-hosted server. Experimental support for Wayland, and can be self-hosted, but glitches when Luppp is opened so I'm not using it for now.
* anydesk-bin - Remote access/support software, works the best for now (Luppp doesn't break it), but requires an X11 session (does not support Wayland at all). This should be used until Rustdesk works properly.
* onlyoffice-bin - MS Office replacement, more compatible and familiar than Libreoffice
* florence - Virtual on-screen keyboard for tablet usage without the keyboard attached
## Remote Support
* As of this writing, setting the session to X11 on the login screen (instead of Wayland) and using AnyDesk works
* rustdesk-nightly almost works in Wayland, but the mouse jumps around
* rustdesk-bin works, but Luppp crashes (segmentation fault) if it is running
## Enable Virtual Keyboard for Login Screen (SDDM)
Create the following file: `/etc/sddm.conf.d/virtualkbd.conf`
```
[General]
InputMethod=qtvirtualkeyboard
```
SDDM now displays a button in lower-left corner of login screen to open the virtual keyboard.

# Non-Interacive Updates
* Copy the update script to home folder: ```cp ./update.sh ~/```
* Increase sudo timeout: ```sudo visudo -f /etc/sudoers.d/99-custom-sudo-timeout```
* Add the line for the timeout in minutes: ```Defaults timestamp_timeout=240```, save and exit.

Sources:
* https://wiki.archlinux.org/title/Pacman/Tips_and_tricks

# Optional Boot Splash
## Plymouth Setup
* Install plymouth and themes: `yay -S plymouth plymouth-kcm breeze-plymouth`
* EndeavourOS uses dracut and not mkinitcpio. You need to edit the kernel parameters for boot to show the splash screen.
* Add/edit the file `/etc/dracut.conf.d/myflags.conf`
* Add the line: `add_dracutmodules+=" plymouth "` and save/exit.
* Regenerate dracut changes: `sudo dracut --force`
## Kernel Parameters
* Edit the file `/etc/kernel/cmdline`
* Add the options `splash silent` to the end of the line, and save/exit.
* Regenerate the boot image: `sudo reinstall-kernels`
* Reboot
Sources:
* https://wiki.archlinux.org/title/Plymouth
* https://discovery.endeavouros.com/installation/systemd-boot/2022/12/

# Login Screen Scaling (SDDM)
* Add/edit the file `/etc/sddm.conf.d/hidpi.conf`
* Add the lines:
```
[Wayland]
EnableHiDPI=true
[X11]
EnableHiDPI=true
[General]
GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=144
```
Sources
* https://www.reddit.com/r/kde/comments/1bahvog/fix_sddm_on_hidpi_screens_on_plasma_6/

# Switching from Grub to Systemd-boot
This is only needed for existing setups where GRUB was chosed over Systemd-boot, and now it is desired to change to Systemd-boot. It is NOT needed in normal setups where Systemd (the default) is chosen in the first place (like when I set up the Surface Pro 3's)
* See https://forum.endeavouros.com/t/tutorial-convert-to-systemd-boot/13290
