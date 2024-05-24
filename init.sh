#!/bin/bash
# "#################################################"
# "Init script to work with this dev container"
# "Instructions:"
# " 1. Open a terminal window and cd into your repo"
# " 3. Run the script, like this:
# "      bash init.sh"
# "#################################################"

# "This function add the font to use in your Bash Terminal."
# "You can have a look on: https://github.com/ryanoasis/nerd-fonts#patched-fonts"
# "if you want to change the font."
install_victor_mono() {
    font_name="Lilex Nerd Font"
    font_url=" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Lilex.zip"
    temp_dir=$(mktemp -d)

    echo "🔤 Installing Font: ${font_name}"

    # Download and extract the font
    curl -s -f -L $font_url -o "${temp_dir}/font.zip"
    unzip -q "${temp_dir}/font.zip" -d "${temp_dir}"

    # Install the font
    sudo cp -r "${temp_dir}/"*.ttf /usr/local/share/fonts/

    # Refresh font cache
    fc-cache -f -v

    echo "🎉 Font ${font_name} installed successfully."
    echo "The bash should look very pretty 🤜🏾🤛🏾"
}

# Display current NodeJs version
echo "  version"
node -v

# Display current npm version
echo "  version"
npm -v

# Display current python version
echo "  version"
python3 --version

# Display current Pip version
echo "Pip version"
pip --version

# Display current Angular version
echo " version"
ng version

# Install npm packages
echo "npm install"
npm install

# Install Victor Mono font
install_victor_mono

# Done!
echo ""
echo "🎉 Congratulations! You've successfully configured Docker Dev Container"
echo ""

# Additional Instructions for the User
echo "📋 Additional Instructions:"
echo ""
echo "🛠️  To run tests for your Angular application, use:"
echo "    ng test"
echo "    This will run the unit tests in your Angular application."
echo ""
echo "🚀  To start your Angular application, use:"
echo "    ng serve"
echo "    This will start a development server and open your application in a web browser."
echo ""
echo "🛠️  To run tests for your FastAPI application, use:"
echo "    pytest"
echo "    Ensure you have pytest installed. This will run your FastAPI tests."
echo ""
echo "🚀  To start your FastAPI application, use:"
echo "    uvicorn main:app --reload"
echo "    Replace 'main' with the name of your Python file. This will start the FastAPI server with auto-reload."

