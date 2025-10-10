# 📸 SayHi - Photo Gallery Application

A full-stack photo gallery application built with Flutter (Mobile) and Spring Boot (Backend), featuring secure authentication, photo upload, preview, and download capabilities.

---

## 🌟 Features

### Core Functionality
- 🔐 **Single User Authentication** - Only one user account allowed (enforced at backend)
- 📤 **Photo Upload** - Upload photos from device gallery
- 🖼️ **Gallery View** - Grid-based photo gallery with thumbnails
- 🔍 **Photo Preview** - Full-screen interactive photo viewer
- 💾 **Photo Download** - Download photos to device
- 🌐 **Dynamic Server Connection** - Connect to any local server via IP address

### Technical Features
- ✅ **MVC Architecture** - Clean separation of concerns in Flutter
- 🗄️ **MySQL Database** - Persistent data storage
- 🔒 **RESTful API** - Well-structured backend endpoints
- 📱 **Cross-Platform** - Works on Android & iOS
- 🚀 **Responsive UI** - Smooth scrolling and keyboard handling

---

## 🏗️ Architecture

### Frontend (Flutter - MVC Pattern)
```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   └── photo.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── server_controller.dart
│   └── gallery_controller.dart
└── views/
    ├── login_view.dart
    ├── ip_address_view.dart
    ├── gallery_view.dart
    └── photo_preview_view.dart
```

### Backend (Spring Boot - Layered Architecture)
```
src/main/java/com/example/sayhi/
├── SayHiApplication.java
├── entity/
│   ├── User.java
│   └── Photo.java
├── repository/
│   ├── UserRepository.java
│   └── PhotoRepository.java
├── model/
│   ├── User.java (DTO)
│   └── Photo.java (DTO)
├── service/
│   ├── UserService.java
│   └── PhotoService.java
└── controller/
    ├── AuthController.java
    └── PhotoController.java
```

---

## 🚀 Getting Started

### Prerequisites

**Backend:**
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+

**Frontend:**
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android/iOS device or emulator

---

## ⚙️ Backend Setup

### 1. Install MySQL

**macOS:**
```bash
brew install mysql
brew services start mysql
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
```

**Windows:**
Download and install from [MySQL Official Website](https://dev.mysql.com/downloads/installer/)

### 2. Create Database

```bash
mysql -u root -p
```

```sql
CREATE DATABASE sayhi_db;
EXIT;
```

### 3. Configure Application

Edit `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/sayhi_db?createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

### 4. Add Dependencies

Ensure `pom.xml` includes:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

### 5. Build and Run

```bash
cd sayhi
mvn clean install
mvn spring-boot:run
```

Server will start on: `http://localhost:8080`

---

## 📱 Frontend Setup

### 1. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

Required dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4
```

### 2. Run the App

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run -d ios
```

**Specific Device:**
```bash
flutter devices
flutter run -d <device-id>
```

---

## 🔌 API Endpoints

### Authentication

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/auth/signup` | Register first user | `{username, password}` | `{success, message}` |
| POST | `/api/auth/login` | Authenticate user | `{username, password}` | `{success, message}` |
| GET | `/api/auth/check` | Check if user exists | - | `{userExists: boolean}` |

### Photos

| Method | Endpoint | Description | Request | Response |
|--------|----------|-------------|---------|----------|
| GET | `/api/photos` | Get all photos | - | `[{id, name, url, thumbnailUrl}]` |
| POST | `/api/photos/upload` | Upload photo | `multipart/form-data` | `{success, message, photoId}` |
| GET | `/api/photos/{id}/download` | Download photo | - | Binary file |
| DELETE | `/api/photos/{id}` | Delete photo | - | `{success, message}` |

---

## 🎯 User Flow

```
1. Launch App
   ↓
2. Enter Server IP Address (e.g., 192.168.1.100:8080)
   ↓
3. Login / Sign Up
   ↓
4. Gallery Page
   ├── View Photos (Grid)
   ├── Upload Photos (FAB button)
   ├── Preview Photos (Tap)
   └── Download Photos (Preview page)
```

---

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);
```

### Photos Table
```sql
CREATE TABLE photos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL
);
```

---

## 🔒 Security Notes

⚠️ **Important**: This is a basic implementation for local use. For production:

- ✅ Implement password hashing (BCrypt)
- ✅ Add JWT token authentication
- ✅ Use HTTPS/TLS encryption
- ✅ Implement rate limiting
- ✅ Add input validation and sanitization
- ✅ Implement proper error handling
- ✅ Add CORS configuration for specific origins

---

## 🐛 Troubleshooting

### Backend Issues

**Problem:** `Communications link failure`
```bash
# Check if MySQL is running
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql
```

**Problem:** `Access denied for user`
```bash
# Reset MySQL root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

**Problem:** Port 8080 already in use
```properties
# Change port in application.properties
server.port=8081
```

### Frontend Issues

**Problem:** Cannot connect to server
- Ensure backend is running
- Check IP address format (e.g., `192.168.1.100:8080`)
- Verify both devices are on same network
- Check firewall settings

**Problem:** Image picker not working
```bash
# Android: Add permissions to AndroidManifest.xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

# iOS: Add to Info.plist
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos</string>
```

---

## 📊 System Requirements

### Backend
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 500MB + photo storage space
- **OS:** Windows 10+, macOS 10.14+, Ubuntu 18.04+

### Frontend
- **RAM:** 2GB minimum
- **Storage:** 500MB app + cache
- **OS:** Android 5.0+ (API 21+), iOS 11.0+

---

## 🛠️ Development

### Running Tests

**Backend:**
```bash
mvn test
```

**Frontend:**
```bash
flutter test
```

### Building for Production

**Backend (JAR):**
```bash
mvn clean package
java -jar target/sayhi-0.0.1-SNAPSHOT.jar
```

**Frontend (APK):**
```bash
flutter build apk --release
```

**Frontend (iOS):**
```bash
flutter build ios --release
```

---

## 📝 Configuration

### File Upload Size Limits

Edit `application.properties`:
```properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

### Upload Directory

```properties
file.upload-dir=./uploads
```

### Database Connection Pool

```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for excellent mobile framework
- Spring Boot team for robust backend framework
- MySQL for reliable database system

---

## 🔄 Version History

### v1.0.0 (2025-10-11)
- ✅ Initial release
- ✅ Single user authentication
- ✅ Photo upload/download
- ✅ Gallery view with preview
- ✅ MySQL database integration

---

**Built with ❤️ using Flutter and Spring Boot**
