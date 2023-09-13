#!/usr/bin/env bash
# A typical structure directories used in my projects

# Usage:./project_structure_generator.sh myProject1
# Or make it executable: sudo ln -sf project_structure_generator.sh /usr/local/bin/project_structure_generator
# And call it from anywhere: project_structure_generator myProject1

clear

# Expected parameters
if [[ $# -ne 1 ]]; then
  echo -e "Project name is required.\nFor example:\nproject_structure_generator.sh myProject1"
  exit 1
fi

project_name=$1

# numerate files to show them in order
mkdir -p "${project_name}"/empirical/0_data/external
mkdir -p "${project_name}"/empirical/0_data/manual

mkdir -p "${project_name}"/empirical/1_code            # link to the code repository + useful scripts

mkdir -p "${project_name}"/empirical/2_pipeline/store    # internal output to avoid re-run the current app
mkdir -p "${project_name}"/empirical/2_pipeline/tmp      # save for inspection purposes or some other temporary reason
mkdir -p "${project_name}"/empirical/2_pipeline/out
mkdir -p "${project_name}"/empirical/2_pipeline/run_logs # the run logs file from the cluster

# contains any final output files that are intended to go public. Includes tables, figures.
mkdir -p "${project_name}"/empirical/3_output/data
mkdir -p "${project_name}"/empirical/3_output/results

mkdir -p "${project_name}"/administrative

mkdir -p "${project_name}"/explorative/img
mkdir -p "${project_name}"/explorative/meetings
mkdir -p "${project_name}"/explorative/plots
mkdir -p "${project_name}"/explorative/notebooks

mkdir -p "${project_name}"/report/img

mkdir -p "${project_name}"/presentation/img