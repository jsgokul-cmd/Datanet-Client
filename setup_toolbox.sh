#!/bin/bash

execute_step() {
    eval "$3"
}

install_toolbox() {
    execute_step 1 "Downloading toolbox bootstrap script" 'curl -X POST \
        --data '"'"'{"os":"osx"}'"'"' \
        -H "Authorization: $(curl -L \
        --cookie $HOME/.midway/cookie \
        --cookie-jar $HOME/.midway/cookie \
        "https://midway-auth.amazon.com/SSO?client_id=https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev&response_type=id_token&nonce=$RANDOM&redirect_uri=https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev:443")" \
        https://us-east-1.prod.release-service.toolbox.builder-tools.aws.dev/v1/bootstrap \
        > ~/toolbox-bootstrap.sh'

    execute_step 2 "Executing bootstrap script" 'bash ~/toolbox-bootstrap.sh'

    execute_step 3 "Removing bootstrap script" 'rm ~/toolbox-bootstrap.sh'

    execute_step 4 "Sourcing shell configuration" 'source ~/.$(basename "$SHELL")rc'
}

install_ada() {
    execute_step 5 "Installing ada using toolbox" 'toolbox install ada'

    execute_step 6 "Remove ada profile" 'ada profile delete --profile redshift'

    execute_step 7 "Updating AWS config" '
    mkdir -p ~/.aws
    if [ ! -f ~/.aws/config ]; then
        touch ~/.aws/config
    fi
    if ! grep -q "\[default\]" ~/.aws/config; then
        echo -e "\n[default]\nregion=us-east-1\noutput=json" >> ~/.aws/config
    fi'

    execute_step 8 "Updating ada credentials" 'ada credentials update --account=862814238953 --provider=conduit --role=IibsAdminAccess-DO-NOT-DELETE --profile=redshift --once'

    execute_step 9 "Adding ada profile" 'ada profile add --account=862814238953 --profile=redshift --provider=conduit --role=RedshiftSDOAccessRole'
}

read -p "If command not found: toolbox? (Y/N): " install_choice

case $install_choice in
    [Yy]*)
        echo "DataClient Installing..."
        install_toolbox
        install_ada
        ;;
    [Nn]*)
        echo "DataClient Installing..."
        install_ada
        ;;
    *)
        echo "Invalid input. Please enter Y or N"
        exit 1
        ;;
esac

echo "All steps completed successfully!"
