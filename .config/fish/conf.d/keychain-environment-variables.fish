### Functions for setting and getting environment variables from the OSX keychain ###
### Adapted from https://www.netmeister.org/blog/keychain-passwords.html ###

# Use: keychain-environment-variable SECRET_ENV_VAR
function keychain-environment-variable --argument-name env_name
  test -z "$env_name"; and echo >&2 "Missing environment variable name"; and return 1
  security find-generic-password -w -a $USER -D "environment variable" -s $env_name
end

# Use: set-keychain-environment-variable SECRET_ENV_VAR
#   provide: super_secret_key_abc123
function set-keychain-environment-variable --argument-name env_name secretinput
  test -z "$env_name"; and echo >&2 "Missing environment variable name"; and return 1
  if count $secretinput > /dev/null
    set secret $secretinput
  else
    read -sP "Enter Value for $env_name: " secret
  end
  if test -n $secret
    security add-generic-password -U -a $USER -D "environment variable" -s $env_name -w $secret
  end
  return 1
end
