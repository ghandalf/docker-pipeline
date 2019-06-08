# GitLab access and configuration

If you read this pabe, it means that your VPN connection is configure. Now, to be able to push code from Git, you have to have some minimal configuration.


## Create or use ssh key

You can use the following steps or read the full (documentation)[http://pipeline.ghandalf.com:32180/help/ssh/README#locating-an-existing-ssh-key-pair]. You need to install (Git Bash)[https://gitforwindows.org/] download and install.

The steps below are for your new Windows 10 machine.

```bash
1. open git bash
2. ssh-keygen -t ed25519 -C "your@email" // Use to identify your key.
3. Just hit enter for default answers. If you enter a passphrase, git will always ask for it when you will pull or push.
4. It will generate the key under ~/.ssh/id_ed25519.pub
5. cat ~/.ssh/id_ed25516.pub | clip // copy the key in memory
```

Go to GitLab settings on rigth side of the screen, then hit SSH keys on left side to insert your key.
![Settings and Ssh Key](./images/GitLab-Settings.png)

Once the key is created and install, you will be able to push, pull, and merge.

