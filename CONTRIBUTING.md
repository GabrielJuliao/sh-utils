## Contributing Guidelines

Welcome to our script repository! Ready to write some shell scripts that are out of this world? Follow these guidelines to make sure your code is ready to launch!

### Script Guidelines

1. **Logging**: Make your scripts as chatty as a parrot in a coffee shop—use `log_info`, `log_warning`, `log_error`, and `log_success` to keep track of what's going on.

   ```bash
   log_info "Starting the super-secret mission to bake the perfect brownies."
   ```

2. **Local Variables**: Keep your variables close, like treasure hidden in a pirate's chest—use `local` to avoid any mutinous conflicts.

   ```bash
   local recipe_file="/path/to/brownie_recipe.txt"
   ```

3. **Readability**: Write your code so even your grandma would understand it—use meaningful names, sprinkle comments like confetti, and make sure it's as neat as your cat's whiskers.

   ```bash
   # Function to mix ingredients for brownies
   mix_brownie_batter() {
       local ingredient=$1
       echo "Mixing $ingredient into the batter."
   }
   ```

4. **Error Handling**: Treat errors like a GPS that wants to send you into the ocean—use `run_and_log` to steer clear of disaster. If something goes wrong, log it, fix it, and move on like a pro.

   ```bash
   # Function to run a command and log its outcome

   # Arguments:
   # $1 - Command to execute
   run_and_log() {
       local command=$1
       log_info "Running command: $command"

       {
           eval "$command"
       } &> >(tee -a "$log_file")

       local exit_code=$?

       if [ $exit_code -ne 0 ]; then
           log_error "Command failed with exit code $exit_code: $command"
           log_info "Check the log file at: \"$log_file\""
           exit $exit_code
       else
           log_success "Command successful: $command"
       fi
   }
   
   run_and_log "brew_coffee"
   ```

5. **Validation**: Don't trust inputs as much as you trust your dog with your sandwich—validate everything. Only take action if you're sure it won't blow up in your face.

   ```bash
   # Validate user input before using it
   if validate_input "$user_input"; then
       run_and_log "process_data $user_input"
       log_success "Data processed successfully: $user_input"
   else
       log_error "Invalid input: $user_input"
   fi
   ```

6. **Function Encapsulation**: Organize your code like a librarian—wrap reusable parts in functions. Each function should have a clear job, like a plumber fixing a leaky faucet.

   ```bash
   # Example of a well-organized function
   deploy_parachute() {
       log_info "Deploying parachute to land safely."

       # Activate parachute deployment system
       run_and_log "activate_parachute"
   }
   ```

7. **Documentation**: Write a README (`README.md`) for your script—think of it as a manual for your robot butler. Explain what your script does, how to use it, what it needs, and any weird quirks.

   ```markdown
   ## Script: ButlerBot

   This script helps ButlerBot organize your sock drawer and brew your morning coffee.
   ```

8. **Testing**: Before releasing your script into the wild, test it like a chef tasting their own food—make sure it works in different scenarios, like when the cat tries to sit on your keyboard.

### Contributing

To contribute your awesome scripts:

1. **Fork** this repository and create a new branch from `main`.

2. **Commit** your changes with clear messages that explain what you did.

   ```bash
   git commit -am 'Add feature/functionality/fix'
   ```

3. **Push** your branch to your forked repository.

   ```bash
   git push origin your-branch-name
   ```

4. **Create a Pull Request (PR)** targeting the `main` branch of the original repository. Describe your changes and why they make our script repository even more awesome.

5. **Review** and address any feedback or comments on your Pull Request.

6. **Merge** your Pull Request once approved and all checks pass.

### License

By contributing, you agree that your scripts will be licensed under the GNU GPL License. For more details, check out the [LICENSE](LICENSE) file.

### Contact

Have questions or need help? Send a message via [GitHub Issues](https://github.com/GabrielJuliao/sh-utils/issues). Now, let's write some scripts that will make the world—or at least the command line—a better place! 🚀