# RailDwarf loco remote

## How to Use this Repository

1. Connect your target hardware to your host computer or network as described
   above
2. Prepare your Phoenix project to build JavaScript and CSS assets:

    ```bash
    cd ui

    # This needs to be repeated when you change dependencies for the UI.
    mix deps.get
    ```

3. Build your assets and prepare them for deployment to the firmware:

    ```bash
    # Still in ui directory from the prior step.
    # This needs to be repeated when you change JS or CSS files.
    mix assets.deploy
    ```

4. Change to the `firmware` app directory

    ```bash
    cd ../firmware
    ```

5. Specify your target and other environment variables as needed:

    ```bash
    export MIX_TARGET=rpi0
    ```

6. Get dependencies, build firmware, and burn it to an SD card:

    ```bash
    mix deps.get
    mix firmware
    mix firmware.burn
    ```

7. Insert the SD card into your target board and connect the USB cable or otherwise power it on
8. Wait for it to finish booting (5-10 seconds)
9. Open a browser window on your host computer to `192.168.0.1`
10. You should see the controller UI
