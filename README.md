# Rick and Morty iOS App. Luscii Edition

by Slava Khlichkin

A SwiftUI iOS application that displays Rick and Morty episodes and character details using the [Rick and Morty API](https://rickandmortyapi.com/documentation/#rest).

## Architecture

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 6.0+

### MVVM-C Pattern
The app follows the MVVM-C (Model-View-ViewModel-Coordinator) architecture:

- **Models**: `Episode`, `Character`, `Origin` with Codable conformance
- **Views**: SwiftUI views for each screen
- **ViewModels**: Business logic and state management
- **Coordinators**: Navigation and dependency injection
- **Services**: API and PDF export services with protocol-based dependency injection

### Key Components

#### Models
- `Episode`: Episode data with character URLs
- `Character`: Character details with all required fields
- `Origin`: Character origin information

#### Services
- `APIService`: Handles API calls using modern concurrency
- `PDFExportService`: Exports character details to PDF
- `MockAPIService`, `PreviewAPIService`, `PreviewPDFExportService` & `MockPDFExportService`: For testing and previews

#### ViewModels
- `EpisodeListViewModel`: Manages episode list with pagination
- `EpisodeDetailViewModel`: Handles character loading for episodes
- `CharacterDetailViewModel`: Manages character details and export

#### Coordinators
- `RootCoordinator`: Main coordinator managing navigation and dependencies
- `Routable` protocol: Type-safe navigation between screens

## Technical Implementation

### API Integration
- Uses the official Rick and Morty API
- Async/await for modern concurrency
- Proper error handling and user feedback
- Cache-busting to prevent stale data

### Navigation
- UIKit-based coordinator pattern
- SwiftUI views embedded via UIHostingController
- Type-safe routing with Routable protocol
- Proper navigation stack management

### Export Functionality
- PDF generation using PDFKit
- Share sheet integration
- Local file storage

### Testing
- Unit tests for all view models
- Mock services for isolated testing
- Coordinator testing
- Comprehensive test coverage

## API Endpoints Used

- `GET /episode` - Fetch episodes with pagination
- `GET /character/{ids}` - Fetch characters by IDs

No single character endpoint fetch been used to optimize networking utilization

## Dependencies

App utilizes no 3rd party tools and minimize issue of conflicts and any possible related problems 

## Testing Strategy

### Unit Tests
- **ViewModels**: Test business logic, state management, and API integration
- **Coordinators**: Test navigation and dependency injection
- **Services**: Test API calls and PDF export functionality

### Mock Services
- `MockAPIService`: Simulates API responses for testing
- `MockPDFExportService`: Simulates PDF export for testing
- `PreviewAPIService`: Provides sample data for SwiftUI previews

## Future Enhancements
### Haven't done this because my dishwasher got broken today and I had to repair it

- **Persistence**: SwiftData integration for offline support
- **Caching**: Image and data caching
- **UI Tests**: Automated UI testing

P.S. Most complicated thing in this assignment was ignoring existing project that I think does the same. But i did my best. 
