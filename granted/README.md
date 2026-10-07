# Support Arc browser

Install granted with brew. 
https://github.com/fwdcloudsec/granted/issues/357


# Supporting WSL
## Method 1: Use File (Insecured but simplest)

1. Update your `~/.granted/config` with file backend
```
...
[Keyring]
  Backend = "file"
```

## Method 2: Use Windows Credential Manager
https://github.com/aws-solutions-library-samples/guidance-for-claude-code-with-amazon-bedrock/issues/266


You can configure Granted to communicate through WSL to the native Windows Credential Manager. This allows you to avoid managing a separate Linux keyring password.
1. Install keyring in your WSL Linux environment via Python pip:bash
```
pip3 install keyring
```

2. Install the Windows Credential Manager backend plugin:bash
```
pip3 install keyring_wincred
```

3. Update your `~/.granted/config` file to instruct Granted to leverage this backend (or set the environment variable if you are using an application that wraps it)
```
...
[Keyring]
  Backend = "secret-service"
```