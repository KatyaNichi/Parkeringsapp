# Parkeringsapp (Server)

The backend server component for the ParkeringsAppen system. This Dart-based server provides a RESTful API for the [Flutter client application](https://github.com/KatyaNichi/ParkeringsAppen).

## Project Overview

This server provides API endpoints for managing:
- Users/persons
- Vehicles
- Parking spaces
- Parking sessions

Data is stored in JSON files for simplicity.

## Features

- RESTful API with Dart and Shelf framework
- JSON file-based data persistence
- Complete API for parking management system
- Clean separation of concerns with repository pattern

## Getting Started

### Prerequisites

- Dart SDK (2.15.0 or later)
- A code editor like VS Code or IntelliJ IDEA

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/KatyaNichi/Parkeringsapp.git
   ```

2. Navigate to the project directory:
   ```
   cd Parkeringsapp
   ```

3. Install dependencies:
   ```
   dart pub get
   ```

4. Run the server:
   ```
   dart run bin/server.dart
   ```

The server will start on port 8080 by default.

## Project Structure

- `bin/server.dart`: Main entry point for the server
- `lib/handlers/`: API endpoint handlers
  - `person_handler.dart`: Person/user management endpoints
  - `vehicle_handler.dart`: Vehicle management endpoints
  - `parking_space_handler.dart`: Parking space management endpoints
  - `parking_handler.dart`: Parking session management endpoints
- `lib/models/`: Data models
- `lib/repositories/`: Data access layer
- `lib/utils/`: Utility functions

The server stores data in JSON files:
- `persons.json`: User information
- `vehicles.json`: Vehicle information
- `parking_spaces.json`: Parking space information
- `parkings.json`: Parking session information

## API Endpoints

### Persons

- `GET /api/persons`: Get all persons
- `GET /api/persons/:id`: Get a specific person
- `POST /api/persons`: Create a new person
- `PUT /api/persons/:id`: Update a person
- `DELETE /api/persons/:id`: Delete a person

### Vehicles

- `GET /api/vehicles`: Get all vehicles
- `GET /api/vehicles/:id`: Get a specific vehicle
- `GET /api/vehicles/owner/:ownerId`: Get vehicles by owner
- `POST /api/vehicles`: Create a new vehicle
- `PUT /api/vehicles/:id`: Update a vehicle
- `DELETE /api/vehicles/:id`: Delete a vehicle

### Parking Spaces

- `GET /api/parkingSpaces`: Get all parking spaces
- `GET /api/parkingSpaces/:id`: Get a specific parking space
- `POST /api/parkingSpaces`: Create a new parking space
- `PUT /api/parkingSpaces/:id`: Update a parking space
- `DELETE /api/parkingSpaces/:id`: Delete a parking space

### Parkings

- `GET /api/parkings`: Get all parkings
- `GET /api/parkings/active`: Get active parkings
- `GET /api/parkings/vehicle/:fordon`: Get parkings by vehicle
- `GET /api/parkings/place/:parkingPlace`: Get parkings by parking place
- `GET /api/parkings/:id`: Get a specific parking
- `POST /api/parkings`: Create a new parking
- `PUT /api/parkings/:id`: Update a parking
- `PUT /api/parkings/:id/end`: End a parking session
- `DELETE /api/parkings/:id`: Delete a parking

## Development

### Running in Development Mode

For development, you can use the Dart development server:

```
dart run --enable-vm-service bin/server.dart
```

This allows for hot reloading and debugging.

### Testing

To run tests:

```
dart test
```

## Client Application

The Flutter client application that consumes this API is available in a separate repository:
[ParkeringsAppen Flutter Client](https://github.com/KatyaNichi/ParkeringsAppen)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
