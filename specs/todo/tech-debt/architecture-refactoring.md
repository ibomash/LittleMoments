# Architecture Refactoring

## Context and Current State

The Little Moments app currently lacks a clear architectural pattern and heavily relies on singletons. The codebase shows inconsistent naming (mixed references to "Little Moments" and "Just Now") and has tight coupling between components, making it difficult to test and maintain.

Current issues include:
- Heavy reliance on singletons (`JustNowSettings.shared`, `HealthKitManager.shared`)
- No clear separation of concerns or architectural pattern
- Mixed naming conventions throughout the codebase
- Tight coupling between view components and business logic

## Motivation and Benefits

Refactoring the architecture will:
- Improve testability by reducing dependencies on singletons
- Make the codebase more maintainable and easier to understand
- Reduce bugs caused by tight coupling
- Provide a consistent structure for future feature development
- Make onboarding new developers easier

## Implementation Plan

### Phase 1: Dependency Injection Framework

1. **Introduce a Dependency Injection System**
   - Create a simple DI container or adopt a lightweight framework
   - Replace direct singleton access with injected dependencies
   - Update constructors to accept dependencies rather than creating them internally

2. **Create Clear Interface Contracts**
   - Define protocols for key services (Settings, HealthKit, Sound)
   - Update implementations to follow these protocols
   - Create mock implementations for testing

### Phase 2: MVVM Architecture Implementation

1. **Formally Adopt MVVM Architecture**
   - Clearly separate Views, ViewModels, and Models
   - Move business logic from views to appropriate ViewModels
   - Ensure ViewModels don't contain UI-specific code

2. **Create Proper Data Models**
   - Extract data structures into dedicated model files
   - Define clear model interfaces
   - Isolate model transformations

### Phase 3: Naming and Organization Cleanup

1. **Standardize App Naming**
   - Decide between "Little Moments" and "Just Now" naming
   - Update all references to be consistent
   - Update file headers and comments

2. **Organize Code by Feature**
   - Restructure files into feature-based directories
   - Group related components together
   - Create a consistent project structure

## Success Metrics

- 80% or more of components should be injectable rather than using singletons directly
- All view components should interact with models only through ViewModels
- 90% code coverage for business logic through unit tests
- Consistent naming throughout the codebase

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Implement changes incrementally with thorough testing after each change |
| Overengineering the solution | Focus on practical improvements rather than theoretical purity |
| Time constraints | Prioritize components by impact; start with most critical services |

## Timeline

- **Week 1-2**: Introduce dependency injection framework and refactor singleton usage
- **Week 3-4**: Implement MVVM pattern fully, starting with the Timer feature
- **Week 5**: Standardize naming and organize codebase
- **Week 6**: Final testing and documentation

## Resources Required

- 1 iOS developer (part-time)
- Access to testing devices running different iOS versions 

## To-Do List (Commits)

### Phase 1: Dependency Injection Framework

1. **Create DI Container Interface**
   - Define the core DI container protocol
   - Implement a basic container class
   - Add documentation and usage examples

2. **Refactor Settings Service**
   - Define `SettingsServiceProtocol`
   - Create implementation that wraps current `JustNowSettings.shared`
   - Update initialization to use DI

3. **Refactor HealthKit Manager**
   - Define `HealthKitServiceProtocol`
   - Create implementation that wraps current `HealthKitManager.shared`
   - Add proper error handling and dependency injection

4. **Refactor Sound Services**
   - Create `SoundServiceProtocol`
   - Implement concrete service class
   - Add unit tests with mock implementations

5. **Create Service Locator**
   - Implement app-wide service locator pattern
   - Configure app initialization to register all services
   - Add documentation for registering new services

### Phase 2: MVVM Architecture Implementation

6. **Create Base ViewModel Infrastructure**
   - Define base ViewModel protocols/classes
   - Add observable property wrappers
   - Document MVVM pattern usage

7. **Refactor Timer Feature to MVVM**
   - Create TimerViewModel
   - Remove business logic from TimerView
   - Add unit tests for TimerViewModel

8. **Refactor Settings UI to MVVM**
   - Create SettingsViewModel
   - Separate UI and business logic
   - Add view state management

9. **Refactor Health Data Views to MVVM**
   - Create HealthDataViewModel
   - Implement proper data transformation logic
   - Add unit tests

10. **Implement Coordinators Pattern**
    - Create app navigation coordinator
    - Remove direct navigation between views
    - Implement hierarchical coordinator structure

### Phase 3: Naming and Organization Cleanup

11. **Standardize App Naming**
    - Decide on final naming convention
    - Update all "JustNow" references to "Little Moments" (or vice versa)
    - Update documentation and comments

12. **Reorganize Project Structure**
    - Create feature-based directory structure
    - Move files to appropriate locations
    - Update imports and references

13. **Clean Up Model Layer**
    - Create proper domain models
    - Remove redundant model code
    - Add serialization/deserialization tests

14. **Implement Style Guide**
    - Create coding style documentation
    - Configure SwiftLint with appropriate rules
    - Fix style violations

15. **Documentation Update**
    - Update README with new architecture description
    - Add architecture diagrams
    - Document key patterns and extension points 