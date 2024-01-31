{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gptcommit;
in {
  options.modules.gptcommit = {
    enable = mkEnableOption "gptcommit";
    openaiModel = mkOption {
      type = types.str;
      description = "The OpenAI model to use";
      default = "gpt-3.5-turbo";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ ];
      file.gptcommit = {
        target = ./. + "/.config/gptcommit/config.toml";
        text = ''
      nixpkgs.localSystem = {
          system = "x86_64-linux";
      };
          model_provider = "openai"
          allow_amend = false
          file_ignore = [
              "package-lock.json",
              "yarn.lock",
              "pnpm-lock.yaml",
              "Cargo.lock",
          ]

          [openai]
          api_base = "https://api.openai.com/v1"
          api_key = ""
          model = "${cfg.openaiModel}"
          retries = 2
          proxy = ""

          [prompt]
          conventional_commit_prefix = """
          You are an expert programmer summarizing a code change.
          You went over every file that was changed in it.
          For some of these files changes where too big and were omitted in the files diff summary.
          Determine the best label for the commit.

          Here are the labels you can choose from:

          - build: changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
          - chore: updating libraries, copyrights or other repo setting, includes updating dependencies.
          - ci: changes to our CI configuration files and scripts (example scopes: Travis, Circle, GitHub Actions)
          - docs: non-code changes, such as fixing typos or adding new documentation
          - feat: a commit of the type feat introduces a new feature to the codebase
          - fix: a commit of the type fix patches a bug in your codebase
          - perf: a code change that improves performance
          - refactor: a code change that neither fixes a bug nor adds a feature
          - style: changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
          - test: adding missing tests or correcting existing tests


          THE FILE SUMMARIES:
          ###
          {{ summary_points }}
          ###

          The label best describing this change:
          """
          commit_summary = """
          You are an expert programmer writing a commit message.
          You went over every file that was changed in it.
          For some of these files changes where too big and were omitted in the files diff summary.
          Please summarize the commit.
          Write your response in bullet points, using the imperative tense.
          Starting each bullet point with a `-`.
          Write a high level description. Do not repeat the commit summaries or the file summaries.
          Write the most important bullet points. The list should not be more than a few bullet points.

          THE FILE SUMMARIES:
          ```
          {{ summary_points }}
          ```

          Remember to write only the most important points and do not write more than a few bullet points.

          THE COMMIT MESSAGE:
          """
          commit_title = """
          You are an expert programmer writing a commit message title.
          You went over every file that was changed in it.
          Some of these files changes were too big, and were omitted in the summaries below.
          Please summarize the commit into a single specific and cohesive theme.
          Write your response using the imperative tense following the kernel git commit style guide.
          Write a high level title.
          Do not repeat the commit summaries or the file summaries.
          Do not list individual changes in the title.
          It MUST NOT be sentence-case, start-case, pascal-case or upper-case
          It MUST NOT end with full stop

          EXAMPLE SUMMARY COMMENTS:
          ```
          raise the amount of returned recordings
          switch to internal API for completions
          lower numeric tolerance for test files
          schedule all GitHub actions on all OSs
          ```

          THE FILE SUMMARIES:
          ```
          {{ summary_points }}
          ```

          Remember to write only one line, no more than 50 characters.
          THE COMMIT MESSAGE TITLE:
          """
          file_diff = """
          You are an expert programmer summarizing a git diff.
          Reminders about the git diff format:
          For every file, there are a few metadata lines, like (for example):
          ```
          diff --git a/lib/index.js b/lib/index.js
          index aadf691..bfef603 100644
          --- a/lib/index.js
          +++ b/lib/index.js
          ```
          This means that `lib/index.js` was modified in this commit. Note that this is only an example.
          Then there is a specifier of the lines that were modified.
          A line starting with `+` means it was added.
          A line that starting with `-` means that line was deleted.
          A line that starts with neither `+` nor `-` is code given for context and better understanding.
          It is not part of the diff.
          After the git diff of the first file, there will be an empty line, and then the git diff of the next file.

          Do not include the file name as another part of the comment.
          Do not use the characters `[` or `]` in the summary.
          Write every summary comment in a new line.
          Comments should be in a bullet point list, each line starting with a `-`.
          The summary should not include comments copied from the code.
          The output should be easily readable. When in doubt, write fewer comments and not more. Do not output comments that
          simply repeat the contents of the file.
          Readability is top priority. Write only the most important comments about the diff.

          EXAMPLE SUMMARY COMMENTS:
          ```
          - raise the amount of returned recordings from `10` to `100`
          - fix a typo in the github action name
          - move the `octokit` initialization to a separate file
          - add an OpenAI API for completions
          - lower numeric tolerance for test files
          - add 2 tests for the inclusive string split function
          ```
          Most commits will have less comments than this examples list.
          The last comment does not include the file names,
          because there were more than two relevant files in the hypothetical commit.
          Do not include parts of the example in your summary.
          It is given only as an example of appropriate comments.


          THE GIT DIFF TO BE SUMMARIZED:
          ```
          {{ file_diff }}
          ```

          THE SUMMARY:
          """
          translation = """
          You are a professional polyglot programmer and translator. You are translating a git commit message.
          You want to ensure that the translation is high level and in line with the programmer's consensus, taking care to keep the formatting intact.

          Translate the following message into {{ output_language }}.

          GIT COMMIT MESSAGE:

          ###
          {{ commit_message }}
          ###

          Remember translate all given git commit message.
          THE TRANSLATION:
          """

          [output]
          conventional_commit = true
          conventional_commit_prefix_format = "{{ prefix }}: "
          lang = "en"
          show_per_file_summary = false
        '';
      };
    };
  };
}
