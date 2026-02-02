# Contributing to Qwen-Claude Setup Scripts

Thank you for your interest in contributing to the Qwen-Claude Setup Scripts project! We welcome contributions from the community to help improve and expand support for more Linux distributions.

## How to Contribute

### Reporting Issues

- Check the issue tracker to see if your issue has already been reported
- Provide detailed information about the problem, including:
  - Your Linux distribution and version
  - The specific error message or unexpected behavior
  - Steps to reproduce the issue
  - Any relevant logs or output

### Adding Support for New Distributions

We're always looking to expand support for additional Linux distributions. To add support for a new distribution:

1. Create a new distribution module in the `distros/` directory following the existing pattern
2. Implement the required functions (`main_setup`, dependency installation, etc.)
3. Test thoroughly on the target distribution
4. Update the documentation as needed
5. Submit a pull request with your changes

### Improving Existing Scripts

- Fix bugs or improve error handling
- Add new features or configuration options
- Improve documentation
- Optimize performance or reliability

## Development Guidelines

### Coding Standards

- Use consistent bash scripting practices
- Include proper error handling and logging
- Follow the existing code structure and naming conventions
- Add comments for complex logic
- Use the shared functions in `common.sh` when appropriate

### Testing

- Test your changes on the relevant distribution(s)
- Verify that the unified installer correctly detects and handles your distribution
- Ensure backward compatibility with existing functionality

### Pull Request Process

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Test thoroughly
5. Update documentation as needed
6. Submit a pull request with a clear description of your changes

## Getting Started

To set up your development environment:

1. Fork and clone the repository
2. Make changes to your local copy
3. Test your changes on the relevant distribution(s)
4. Commit your changes with descriptive commit messages
5. Push your changes to your fork
6. Submit a pull request

## Questions?

If you have any questions about contributing, feel free to open an issue in the issue tracker.

Thank you for your contributions!