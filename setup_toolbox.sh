#!/bin/bash

execute_step() {
    echo "Step $1: $2"
    sleep 2  
    eval "$3"
    echo "Step $1 completed"
    echo "-------------------"
    sleep 1  
}

install_toolbox() {
    echo "Starting ToolBox installation..."
    sleep 1

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
    echo "Starting Ada installation and configuration..."
    sleep 1

    execute_step 5 "Installing ada using toolbox" 'toolbox install ada'

    execute_step 6 "Remove ada profile" 'ada profile delete --profile redshift'

    execute_step 7 "Updating ada credentials" 'ada credentials update --account=862814238953 --provider=conduit --role=IibsAdminAccess-DO-NOT-DELETE --profile=redshift --once'

    execute_step 8 "Adding ada profile" 'ada profile add --account=862814238953 --profile=redshift --provider=conduit --role=RedshiftSDOAccessRole'
}


read -p "If command not found: toolbox? (Y/N): " install_choice

case $install_choice in
    [Yy]*)
        install_toolbox
        install_ada
        ;;
    [Nn]*)
        install_ada
        ;;
    *)
        echo "Invalid input. Please enter Y or N"
        exit 1
        ;;
esac

echo "All steps completed successfully!"
