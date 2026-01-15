# Inventro - Complete Project File Structure

## 📁 Project Overview
**Inventro** is a Flutter-based inventory management application with role-based access (Manager & Employee) built using GetX state management, following clean architecture principles.

---

## 🗂️ Root Directory Structure

```
inventro/
├── android/                          # Android native configuration
├── assets/                           # Static assets (images, fonts, etc.)
├── build/                            # Build output files
├── ios/                              # iOS native configuration
├── lib/                              # Main Flutter application code
├── linux/                            # Linux desktop configuration
├── macos/                            # macOS desktop configuration
├── test/                             # Unit and widget tests
├── web/                              # Web platform configuration
├── windows/                          # Windows desktop configuration
├── analysis_options.yaml             # Dart analyzer configuration
├── devtools_options.yaml             # Flutter DevTools configuration
├── inventro.iml                      # IntelliJ IDEA module file
├── pubspec.lock                      # Locked dependency versions
├── pubspec.yaml                      # Project dependencies and metadata
└── README.md                         # Project documentation
```

---

## 📱 Main Application Structure (`lib/`)

```
lib/
├── main.dart                         # Application entry point & lifecycle observer
└── app/                              # Core application module
    ├── data/                         # Data layer (models & services)
    ├── middleware/                   # Route middleware
    ├── modules/                      # Feature modules
    ├── routes/                       # Application routing
    └── utils/                        # Utility functions and helpers
```

---

## 🗄️ Data Layer (`lib/app/data/`)

### 📊 Models (`lib/app/data/models/`)
```
data/models/
├── bulk_upload_result.dart           # Bulk upload operation result model
├── employee_model.dart               # Employee data model
├── product_model.dart                # Product/inventory item model
└── user_model.dart                   # User/Manager account model
```

### 🔧 Services (`lib/app/data/services/`)
```
data/services/
├── auth_service.dart                 # Authentication & authorization service
├── company_service.dart              # Company CRUD operations
├── employee_service.dart             # Employee management service
├── product_service.dart              # Product/inventory management service
└── session_recovery_service.dart     # Session persistence & recovery
```

---

## 🛣️ Routing (`lib/app/routes/`)

```
routes/
├── app_pages.dart                    # Route definitions with bindings
└── app_routes.dart                   # Route path constants
```

**Available Routes:**
- `/splash` - Splash screen
- `/role-selection` - Manager/Employee role selection
- `/login` - Manager login
- `/register` - Manager registration
- `/dashboard` - Manager dashboard
- `/add-employee` - Add employee form
- `/add-product` - Add product form
- `/edit-product` - Edit product form
- `/manager-profile` - Manager profile view
- `/employee-list` - Employee list view
- `/employee-login` - Employee login
- `/employee-dashboard` - Employee dashboard
- `/bulk-upload` - Bulk product upload
- `/create-company` - Company creation
- `/about-us` - About us page

---

## 🔐 Middleware (`lib/app/middleware/`)

```
middleware/
└── auth_middleware.dart              # Authentication route guard
```

---

## 🎯 Modules (`lib/app/modules/`)

### 📖 About Us Module (`lib/app/modules/about_us/`)
```
about_us/
├── about_us_page.dart                # Main about us page
└── widgets/
    ├── about_us_header.dart          # Header section
    ├── company_attribution.dart      # Company info attribution
    └── team_members_section.dart     # Team members display
```

### 🔑 Auth Module (`lib/app/modules/auth/`)

#### Controllers (`lib/app/modules/auth/controller/`)
```
auth/controller/
├── add_employee_controller.dart      # Add employee logic
├── add_product_controller.dart       # Add product logic
├── auth_controller.dart              # Main authentication controller
├── bulk_upload_controller.dart       # Bulk upload logic
├── company_controller.dart           # Company management logic
├── dashboard_controller.dart         # Manager dashboard logic
├── edit_product_controller.dart      # Edit product logic
├── employee_dashboard_controller.dart # Employee dashboard logic
├── employee_list_controller.dart     # Employee list logic
└── employee_login_controller.dart    # Employee login logic
```

#### Bindings (`lib/app/modules/auth/bindings/`)
```
auth/bindings/
├── add_employee_binding.dart         # Add employee dependencies
├── add_product_binding.dart          # Add product dependencies
├── bulk_upload_binding.dart          # Bulk upload dependencies
├── dashboard_binding.dart            # Manager dashboard dependencies
├── edit_product_binding.dart         # Edit product dependencies
├── employee_dashboard_binding.dart   # Employee dashboard dependencies
└── employee_list_binding.dart        # Employee list dependencies
```

#### Views - Common (`lib/app/modules/auth/views/`)
```
auth/views/
├── role_selection_screen.dart        # Manager/Employee role selection
└── splash_screen.dart                # Initial splash screen
```

#### Views - Manager (`lib/app/modules/auth/views/manager/`)
```
auth/views/manager/
├── add_employee_screen.dart          # Add employee screen
├── add_product_screen.dart           # Add product screen
├── bulk_upload_screen.dart           # Bulk product upload screen
├── company_creation_page.dart        # Company creation page
├── company_details_screen.dart       # Company details view
├── create_company_screen.dart        # Create company screen
├── dashboard.dart                    # Manager main dashboard
├── edit_product_screen.dart          # Edit product screen
├── employee_list_screen.dart         # Employee list screen
├── login_screen.dart                 # Manager login screen
├── manager_registration_screen.dart  # Manager registration screen
├── profile_screen.dart               # Manager profile screen
└── widgets/                          # Manager-specific widgets
```

##### Manager Widgets - Bulk Upload (`lib/app/modules/auth/views/manager/widgets/bulk_upload_widgets/`)
```
widgets/bulk_upload_widgets/
├── duplicate_action_selector.dart    # Duplicate handling options
├── file_picker_zone.dart             # File picker component
├── glass_card.dart                   # Glassmorphism card wrapper
├── instruction_section.dart          # Upload instructions
└── upload_result_view.dart           # Upload result display
```

##### Manager Widgets - Company (`lib/app/modules/auth/views/manager/widgets/company_widgets/`)
```
widgets/company_widgets/
├── company_creation_app_bar.dart     # Company creation app bar
├── company_creation_button.dart      # Creation action button
├── company_creation_error_message.dart # Error display
├── company_creation_header.dart      # Creation header section
└── company_creation_input_field.dart # Input field component
```

##### Manager Widgets - Dashboard (`lib/app/modules/auth/views/manager/widgets/dashboard_widgets/`)
```
widgets/dashboard_widgets/
├── dashboard_actions.dart            # Quick action buttons
├── dashboard_bottom_nav.dart         # Bottom navigation bar
├── dashboard_gradient_background.dart # Gradient background
├── dashboard_header.dart             # Dashboard header
├── dashboard_scrollable_content.dart # Scrollable content wrapper
├── dashboard_section_divider.dart    # Section divider
├── dashboard_stat_cards.dart         # Statistics cards
├── unified_dashboard_card.dart       # Unified info card
└── welcome_card.dart                 # Welcome message card
```

##### Manager Widgets - Employee Management (`lib/app/modules/auth/views/manager/widgets/employee_widgets/`)
```
widgets/employee_widgets/
├── add_employee_form.dart            # Add employee form
├── add_employee_header.dart          # Add employee header
├── company_limit_banner.dart         # Employee limit banner
├── employee_list_content.dart        # Employee list content
├── employee_list_header.dart         # Employee list header
├── employee_search_bar.dart          # Employee search
├── employee_text_field.dart          # Employee input field
├── employee_tile.dart                # Employee list item
└── submit_employee_button.dart       # Submit button
```

##### Manager Widgets - Product Management (`lib/app/modules/auth/views/manager/widgets/product_widgets/`)
```
widgets/product_widgets/
├── add_product_form.dart             # Add product form
├── add_product_header.dart           # Add product header
├── edit_product_form.dart            # Edit product form
├── edit_product_header.dart          # Edit product header
├── expiry_date_picker.dart           # Date picker component
├── product_detail_dialog.dart        # Product details dialog
├── product_grid.dart                 # Product grid view
├── product_screen_app_bar.dart       # Product screen app bar
├── product_screen_layout.dart        # Product screen layout
├── product_text_field.dart           # Product input field
├── submit_product_button.dart        # Submit product button
└── update_product_button.dart        # Update product button
```

##### Manager Widgets - Profile (`lib/app/modules/auth/views/manager/widgets/profile_widgets/`)
```
widgets/profile_widgets/
├── account_actions_card.dart         # Account actions (logout, etc.)
├── company_info_card.dart            # Company information card
├── personal_info_card.dart           # Personal info display
└── profile_header.dart               # Profile header section
```

##### Manager Widgets - Shared (`lib/app/modules/auth/views/manager/widgets/shared_widgets/`)
```
widgets/shared_widgets/
├── company_id_input.dart             # Company ID input
├── company_validation_status.dart    # Validation status display
├── manager_details_form.dart         # Manager details form
└── registration_actions.dart         # Registration action buttons
```

#### Views - Employee (`lib/app/modules/auth/views/employee/`)
```
auth/views/employee/
├── employee_login_screen.dart        # Employee login screen
├── dashboard/                        # Employee dashboard
│   ├── dashboard.dart                # Main employee dashboard
│   └── widgets/                      # Dashboard-specific widgets
└── profile/                          # Employee profile
    └── employee_profile_section.dart # Profile section component
```

##### Employee Dashboard Widgets (`lib/app/modules/auth/views/employee/dashboard/widgets/`)
```
dashboard/widgets/
├── employee_dashboard_app_bar.dart   # Employee dashboard app bar
├── employee_dashboard_background.dart # Dashboard background
├── employee_product_card.dart        # Product card (read-only)
├── employee_product_list.dart        # Product list view
├── employee_profile_section.dart     # Profile section (in app bar)
└── employee_search_bar.dart          # Product search bar
```

---

## 🛠️ Utilities (`lib/app/utils/`)

```
utils/
├── responsive_utils.dart             # Responsive design utilities
├── safe_controller_base.dart         # Base controller with safe navigation
└── safe_navigation.dart              # Safe navigation helpers
```

### Utility Functions:
- **responsive_utils.dart**: Screen size calculations, responsive padding/margin
- **safe_controller_base.dart**: Abstract base controller for safe lifecycle management
- **safe_navigation.dart**: Navigation guards, safe snackbar, authentication checks

---

## 🎨 Assets Structure (`assets/`)

```
assets/
└── images/
    └── logo.jpg                      # Application logo
```

---

## 🏗️ Architecture Overview

### Design Pattern: **MVC + Clean Architecture**
- **Models**: Data structures (`lib/app/data/models/`)
- **Services**: Business logic & API calls (`lib/app/data/services/`)
- **Controllers**: State management (`lib/app/modules/auth/controller/`)
- **Views**: UI components (`lib/app/modules/auth/views/`)
- **Widgets**: Reusable UI components (within respective views)

### State Management: **GetX**
- Controllers use `GetxController`
- Bindings for dependency injection
- Reactive state with `.obs` observables

### Navigation: **GetX Routing**
- Centralized route definitions in `app_pages.dart`
- Named routes in `app_routes.dart`
- Middleware for authentication guards

---

## 🔑 Key Features by Module

### 👔 Manager Features
- ✅ Company creation and management
- ✅ Employee CRUD operations
- ✅ Product/Inventory CRUD operations
- ✅ Bulk product upload (Excel/CSV)
- ✅ Dashboard with statistics
- ✅ Profile management
- ✅ Employee limit tracking

### 👷 Employee Features
- ✅ Read-only product access
- ✅ Product search functionality
- ✅ Profile view
- ✅ Expiry date tracking
- ✅ Clean, simplified dashboard

### 🔐 Authentication
- ✅ Manager login (email + password)
- ✅ Employee login (email + PIN)
- ✅ Session persistence
- ✅ Session recovery
- ✅ Role-based access control

---

## 📦 Dependencies (from pubspec.yaml)

### Core Flutter
- `flutter_sdk`
- `cupertino_icons: ^1.0.8`

### State Management & Navigation
- `get: ^4.7.2` - GetX for state management and routing

### HTTP & API Communication
- `http: ^1.3.0` - HTTP client for REST API calls
- `path: ^1.9.1` - Path manipulation for URL construction

### Local Storage
- `shared_preferences: ^2.5.3` - Persistent key-value storage for session data
- `get_storage: ^2.1.1` - Fast key-value storage solution

### File Operations
- `file_picker: ^10.3.7` - File picker for bulk upload functionality
- `path_provider: ^2.1.5` - Access to device file system paths

### Utilities
- `intl: ^0.19.0` - Internationalization and date formatting
- `permission_handler: ^12.0.1` - Handle device permissions

### Backend
- **Custom REST API**: `https://backend.tecsohub.com/`
  - Authentication endpoints
  - Company management
  - Employee management
  - Product/inventory management
  - Bulk upload processing

---

## 🧪 Testing Structure (`test/`)

```
test/
└── widget_test.dart                  # Widget tests
```

---

## 📝 Configuration Files

### Analysis & Code Quality
- **analysis_options.yaml**: Dart linter rules
- **devtools_options.yaml**: Flutter DevTools settings

### Platform-Specific
- **android/**: Android Gradle, manifest, permissions
- **ios/**: iOS Runner, Info.plist, CocoaPods
- **web/**: index.html, manifest.json, favicon
- **windows/**: CMake configuration
- **linux/**: CMake configuration
- **macos/**: Xcode project, Runner

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for platforms
```bash
# Android
flutter build apk

# iOS (requires macOS)
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

---

## 📊 Project Statistics

- **Total Dart Files**: 100+
- **Controllers**: 10
- **Views**: 20+
- **Reusable Widgets**: 60+
- **Services**: 5
- **Models**: 4
- **Bindings**: 7

---

## 🎯 Code Organization Principles

1. **Feature-based organization**: Each module contains its own controllers, views, and widgets
2. **Separation of concerns**: Data, business logic, and UI are clearly separated
3. **Reusability**: Widgets are broken down into small, reusable components
4. **Type safety**: Strong typing with Dart models
5. **Reactive programming**: GetX observables for state management
6. **Clean architecture**: Clear boundaries between layers

---

## 📞 Support & Contact

For issues, questions, or contributions, please refer to the project repository.

---

**Last Updated**: January 11, 2026
**Flutter Version**: 3.x
**Dart Version**: 3.x

---

## 📜 License

See LICENSE file in the project root.
