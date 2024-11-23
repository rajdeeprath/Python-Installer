# Python installer and virtual environment setup script

<p>
    This is a script used to setup and manage python3 projects & virtual environments
</p>
<p>
    Works on popular linux OS Debian, Ubuntu, Redhat, CentOs, Fedora
</p>
<p>
    It provides the following features:
</p>
<ul>
    <li>Create a new virtual environment</li>
    <li>Delete a virtual environment</li>
    <li>List existing virtual environments</li>
    <li>Load existing python3 project</li>
</ul>
<h4>INSTALLATION</h4>

<code>
    curl https://raw.githubusercontent.com/connessionetech/python-installer/master/install.sh | sh -
</code>

<h4>USAGE</h4>
<ul>
    <li>The command used is <strong>pysetenv</strong></li>
    <ul>
        <li><strong>pysetenv -h name| pysetenv --help name</strong> to show pysetenv usage</li>
        <li><strong>pysetenv -l name| pysetenv --list name</strong> to list existing virtual environments</li>
        <li><strong>pysetenv -n name| pysetenv --new name</strong> to create new virtual environment</li>
        <li><strong>pysetenv -d name| pysetenv --delete name</strong> to delete a virtual environment</li>
    </ul>

<h4>CONFIGURATION</h4>
<p>Configurables are</p>
<ul>
    <li><strong>PYSETENV_VIRTUAL_DIR_PATH</strong>  This is the root Path for virtual environments</li>
    <li><strong>PYSETENV_PYTHON_VERSION</strong>  This the python version to use. The default is python3</li>
    <li><strong>PYSETENV_PYTHON_PATH</strong> This is the python installation folder in the system</li>
</ul>
<h4>Switching between virtual environment</h4>
<p>on the terminal type the following to switch from foo to bar virtual environment</p>
<code>pysetenv bar</code>
<h4>Deactivate</h4>
<p>Type this on terminal to deactivate virtual environment</p>
<code>deactivate</code>


## Supported platforms

| OS  | Python Versions  | Comment/note  |   |   |
|---|---|---|---|---|
| Ubuntu 20.x  | |   |   |   |
| Ubuntu 18.x  | 3.6, 3.7, 3.8 |   |   |   |
| Ubuntu 16.x  | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |
| Debian 10 | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |
| CentOs 6.x | x |   |   |   |
| CentOs 7.x | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |
| CentOs 8.x | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |
| Red Hat 7.x | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |
| Red Hat 8.x | 3.5, 3.6, 3.7, 3.8, 3.9 |   |   |   |


