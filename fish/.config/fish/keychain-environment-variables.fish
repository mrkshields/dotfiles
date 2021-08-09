### Functions for setting and getting environment variables from the OSX keychain ###
### Adapted from https://www.netmeister.org/blog/keychain-passwords.html ###

# Use: keychain-environment-variable SECRET_ENV_VAR
function keychain-environment-variable
  security find-generic-password -w -a $USER -D "environment variable" -s $argv
end

# Use: set-keychain-environment-variable SECRET_ENV_VAR
#   provide: super_secret_key_abc123
function set-keychain-environment-variable --argument-name env_name
  
  test -n "$env_name"; or echo "Missing environment variable name"
  read -ps "Enter Value for $env_name: " secret
  if test -n $1
    if test -n $secret
      security add-generic-password -U -a $USER -D "environment variable" -s $env_name -w $secret
    end
  end
  return 1
end
