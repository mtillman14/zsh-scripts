#!/usr/bin/env zsh

#!/usr/bin/env zsh

# Function to prompt for input using AppleScript with cancellation handling
prompt_for_input() {
    prompt_message=$1
    default_value=$2
    osascript -e "try
        display dialog \"$prompt_message\" default answer \"$default_value\"
        set userInput to text returned of result
    on error
        return \"CANCELLED\"
    end try"
}

# 1. Get the first input. If none is provided, use the current working directory
if [[ -z $1 ]]; then
    project_folder=$(pwd)
else
    project_folder=$1
fi

# Make the folder if it doesn't exist
mkdir -p $project_folder

cd "$project_folder"

# Get user input for constants
author=$(prompt_for_input "Enter the author name:" "Mitchell Tillman")

email=$(prompt_for_input "Enter the author email:" "mtillman14@gmail.com")

project_name=$(prompt_for_input "Enter the project name:" "Test_Template")

# Replace spaces and hyphens with underscores in the project name
underscore_project_name=${project_name//-/_}
underscore_project_name=${underscore_project_name// /_}

# 2. Create a virtual environment named .venv in the project folder
cd $project_folder
python3 -m venv .venv

# 3. Activate the virtual environment
source "$project_folder/.venv/bin/activate"

# 4. Install the required packages
touch requirements.txt

# Add the required packages to the requirements.txt file
required_packages_list=(
  'mkdocs' 
  'pytest' 
  'toml' 
  'mkdocs-material' 
  'mkdocs-git-revision-date-localized-plugin' 
  'mkdocs-awesome-pages-plugin' 
  'mkdocstrings'
)
for package in ${required_packages_list[@]}; do
    echo "$package" >> requirements.txt
done

# 5. Create the required files.
pyproject_toml_content="
[build-system]
requires = ['hatchling']
build-backend = 'hatchling.build'

[project]
name = \"$project_name\"
version = '0.1.0'
description = 'A template for a Python project.'
authors = [{name = \"$author\", email =\"$email\"}]
dependencies = [

]
"

# Define the raw content for mkdocs.yml
mkdocs_yml_content="
site_name: \"$project_name\"
site_author: \"$author\"
repo_name: \"$repo_name\"
repo_url: \"https://github.com/$github_user/$repo_name\"
site_url: \"https://researchos.github.io/$repo_name/\"
theme:
  name: material
  features:
    - navigation.path
    - navigation.tabs
    - navigation.tabs.sticky
    - navigation.expand
    - toc.follow
    - navigation.top
    - content.code.copy

plugins:
  - search  
  - awesome-pages
  - mkdocstrings:
      default_handler: python
      handlers:
        python:
          rendering:
            show_source: false
            show_signature: true
            show_docstrings: true
          selection:
            members: true
            docstring_style: \"google\"
          options:
            filters:
              - \"!^__.*__$\"
              - \"!^_\"

markdown_extensions:
  - pymdownx.highlight:
      use_pygments: true
  - pymdownx.superfences
  - admonition
"

# Define the raw content for tests/test_main.py
test_main_py_content="
import pytest

def test_$underscore_project_name():
    assert 1 + 1 == 2

if __name__ == '__main__':
    pytest.main([__file__])
"

pages_content="
nav:
  - Home: index.md
"

# Create the docs folder.
mkdir -p docs

# Create the tests folder
mkdir -p tests

mkdir -p src/$project_name

# pyproject.toml
if [[ ! -e "$project_folder/pyproject.toml" ]]; then
    echo "$pyproject_toml_content" > pyproject.toml
fi

# mkdocs.yml
if [[ ! -e "$project_folder/mkdocs.yml" ]]; then
    echo "$mkdocs_yml_content" > mkdocs.yml
fi

# tests/test_main.py
if [[ ! -e "$project_folder/tests/test_main.py" ]]; then
    echo "$test_main_py_content" > tests/test_main.py
fi

# docs/index.md
if [[ ! -e "$project_folder/docs/index.md" ]]; then
    echo "# $project_name" > docs/index.md
fi

# docs/.pages
if [[ ! -e "$project_folder/docs/.pages" ]]; then
    echo "$pages_content" > docs/.pages
fi

# src/$project_name/__init__.py
if [[ ! -e "$project_folder/src/$project_name/__init__.py" ]]; then
    touch src/$project_name/__init__.py
fi

# src/$project_name/__main__.py
if [[ ! -e "$project_folder/src/$project_name/__main__.py" ]]; then
    touch src/$project_name/__main__.py
    echo "def main():
    pass

if __name__ == '__main__':
    pass" > src/$project_name/__main__.py
fi

if [[ ! -e "$project_name/docs/.pages" ]]; then
    touch $project_name/docs/.pages
    echo "nav:
    - Home: index.md" > $project_name/docs/.pages
fi

pip install -r requirements.txt

echo "" # Newline
echo "~/scripts/vvenv.zsh successfully created the project folder."

# .gitignore
gitignore_content="/.venv
*.DS_Store"
if [[ ! -e "$project_folder/.gitignore" ]]; then
    echo "$gitignore_content" > .gitignore
fi

# Check if .git file exists in the folder
if [[ ! -e "$project_folder/.git" ]]; then

    github_user=$(prompt_for_input "Enter your GitHub username:" "mtillman14")
    repo_name=$project_name

    # Create the git repository
    git init "$project_folder"
    git branch -M main
    git add .
    git commit -m "Initial commit"
    if ! gh repo view "$github_user/$repo_name" >/dev/null 2>&1; then
        gh repo create "$github_user/$repo_name" --public # Initialize the repository on github
        git remote add origin "https://github.com/$github_user/$repo_name.git"
    fi    
    git push -u origin main
fi

source .venv/bin/activate # Activate the virtual environment

# mkdocs serve # Show the docs in the browser