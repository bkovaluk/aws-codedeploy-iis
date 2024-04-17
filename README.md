# aws-codedeploy-iis

**aws-codedeploy-iis** is a centralized repository for managing AWS CodeDeploy logic for multiple applications across various environments. It simplifies the deployment process by providing a standard set of CodeDeploy scripts and configurations.

## Table of Contents

- [Introduction](#introduction)
- [Repository Structure](#repository-structure)

## Introduction

Managing AWS CodeDeploy deployments for multiple applications and environments can become complex. **aws-codedeploy-iis** aims to streamline this process by offering a centralized location for managing deployment logic. This repository provides a set of CodeDeploy scripts and configurations that can be easily customized and reused for various applications and environments.

## Repository Structure

The repository structure is organized to keep deployment-related files and configurations well-organized:

- **appspec.yml**: The main AWS CodeDeploy Application Specification file that defines the deployment process.
- **conf/**: Contains IIS site configurations used in deployment scripts.
- **scripts/**: Houses deployment scripts that handle different stages of deployment:
  - `cleanup.ps1`: Script for cleaning up before installation.
  - `stage_artifacts.ps1`: Script for staging deployment artifacts.
  - `create_sites.ps1`: Script for creating IIS sites using configurations from the `conf` directory.
  - `start_services.ps1`: Script for starting services after installation.

