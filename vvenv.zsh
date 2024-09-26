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

# Check if the folder is empty
if [[ -n $(ls -A $project_folder) ]]; then
    echo 'The folder is not empty.'
    exit 1
fi

# Get user input for constants
author=$(prompt_for_input "Enter the author name:" "Mitchell Tillman")
[[ $author == "CANCELLED" ]] && echo "Process cancelled by user." && exit 1

email=$(prompt_for_input "Enter the author email:" "mtillman14@gmail.com")
[[ $email == "CANCELLED" ]] && echo "Process cancelled by user." && exit 1

project_name=$(prompt_for_input "Enter the project name:" "Test_Template")
[[ $project_name == "CANCELLED" ]] && echo "Process cancelled by user." && exit 1

github_user=$(prompt_for_input "Enter your GitHub username:" "mtillman14")
[[ $github_user == "CANCELLED" ]] && echo "Process cancelled by user." && exit 1

repo_name=$(prompt_for_input "Enter the repository name:" "test_template")
[[ $repo_name == "CANCELLED" ]] && echo "Process cancelled by user." && exit 1

# Create the git repository
git init $project_folder
git add .
git commit -m "Initial commit"
git remote add origin "https://github.com/$github_user/$repo_name.git"

# 2. Create a virtual environment named .venv in the project folder
cd $project_folder
python3 -m venv .venv

# 3. Activate the virtual environment
source "$project_folder/.venv/bin/activate"

# 4. Install the required packages
touch requirements.txt

# Add the required packages to the requirements.txt file
required_packages_list=('mkdocs' 'pytest' 'toml' 'mkdocs-material' 'mkdocs-git-revision-date-localized-plugin' 'mkdocs-awesome-pages-plugin' 'mkdocstrings')
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
dependencies = []
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
nav:
  - Home: docs/index.md

theme:
  name: 'mkdocs'

markdown_extensions:
  - toc:
      permalink: true
"

# Define the raw content for tests/test_main.py
test_main_py_content="
import pytest

def test_$project_name():
    assert 1 + 1 == 2

if __name__ == '__main__':
    pytest.main([__file__])
"

# Create the docs folder.
mkdir -p docs

# Create the tests folder
mkdir -p tests

echo "$pyproject_toml_content" > pyproject.toml
echo "$mkdocs_yml_content" > mkdocs.yml
echo "$test_main_py_content" > tests/test_main.py
echo "# $project_name" > docs/index.md

pip install -r requirements.txt

echo "" # Newline
echo "~/scripts/vvenv.zsh successfully created the project folder."

# mkdocs gh-deploy


#-----------------------------------------------------------------------------------------------------------------------
# FUNCTIONAL!!!!!!!

# author='Mitchell Tillman'
# email='mtillman14@gmail.com'
# project_name='Test_Template'
# github_user='mtillman14'
# repo_name='test_template'

# # 1. Get the first input. If none is provided, use pwd
# if [[ -z $1 ]]; then
#     project_folder=$(pwd)
# else
#     project_folder=$1
# fi

# # Check if the contents of the folder are empty
# if [[ -n $(ls -A $project_folder) ]]; then
#     echo 'The folder is not empty.'
#     exit 1
# fi

# # Create the git repository
# git init $project_folder
# git add .
# git commit -m "Initial commit"
# git remote add origin "https://github.com/mtillman14/$project_name.git"

# # 2. Create a virtual environment name .venv in the project folder
# cd $project_folder
# python3 -m venv .venv

# # 3. Activate the virtual environment
# source "$project_folder/.venv/bin/activate"

# # 4. Install the required packages
# touch requirements.txt

# # Add the required packages to the requirements.txt file
# required_packages_list=('mkdocs' 'pytest' 'toml' 'mkdocs-material' 'mkdocs-git-revision-date-localized-plugin' 'mkdocs-awesome-pages-plugin' 'mkdocstrings')
# for package in ${required_packages_list[@]}; do
#     echo "$package" >> requirements.txt
# done

# # 5. Create the required files.
# pyproject_toml_content="
# [build-system]
# requires = ['hatchling']
# build-backend = 'hatchling.build'

# [project]
# name = \"$project_name\"
# version = '0.1.0'
# description = 'A template for a Python project.'
# authors = [{name = \"$author\", email =\"$email\"}]
# dependencies = []
# "

# # Define the raw content for mkdocs.yml
# mkdocs_yml_content="
# site_name: \"$project_name\"
# site_author: \"$author\"
# repo_name: \"$repo_name\"
# repo_url: \"https://github.com/$github_user/$repo_name\"
# site_url: \"https://researchos.github.io/$repo_name/\"
# theme:
#   name: material
#   features:
#     - navigation.path
#     - navigation.tabs
#     - navigation.tabs.sticky
#     - navigation.expand
#     - toc.follow
#     - navigation.top

# plugins:
#   - search  
#   - awesome-pages
#   - mkdocstrings:
#       default_handler: python
#       handlers:
#         python:
#           rendering:
#             show_source: false
#             show_signature: true
#             show_docstrings: true
#           selection:
#             members: true
#             docstring_style: \"google\"
#           options:
#             filters:
#               - \"!^__.*__$\"
#               - \"!^_\"

# markdown_extensions:
#   - pymdownx.highlight:
#       use_pygments: true
#   - pymdownx.superfences
#   - admonition
# nav:
#   - Home: docs/index.md

# theme:
#   name: 'mkdocs'

# markdown_extensions:
#   - toc:
#       permalink: true
# "

# # Define the raw content for tests/test_main.py
# test_main_py_content="
# import pytest

# def test_$project_name():
#     assert 1 + 1 == 2

# if __name__ == '__main__':
#     pytest.main([__file__])
# "

# # Create the docs folder.
# mkdir -p docs

# # Create the tests folder
# mkdir -p tests

# echo "$pyproject_toml_content" > pyproject.toml
# echo "$mkdocs_yml_content" > mkdocs.yml
# echo "$test_main_py_content" > tests/test_main.py
# echo "# $project_name" > docs/index.md

# pip install -r requirements.txt

# echo "Successfully created the project folder."

# # mkdocs gh-deploy