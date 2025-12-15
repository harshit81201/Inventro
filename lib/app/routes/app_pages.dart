import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/employee/employee_login_screen.dart';
import 'package:inventro/app/modules/auth/views/employee/dashboard/dashboard.dart';
import 'package:inventro/app/modules/auth/views/manager/add_employee_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/add_product_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/edit_product_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/dashboard.dart';
import 'package:inventro/app/modules/auth/views/manager/employee_list_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/login_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/profile_screen.dart';
import 'package:inventro/app/modules/auth/views/role_selection_screen.dart';
import 'package:inventro/app/modules/auth/views/splash_screen.dart';
import '../modules/auth/views/manager/company_creation_page.dart';
import '../modules/auth/views/manager/create_company_screen.dart';
import '../modules/auth/views/manager/manager_registration_screen.dart';
import '../modules/about_us/about_us_page.dart';
// FIXED: Import all lazy bindings
import '../modules/auth/views/manager/bulk_upload_screen.dart';
import '../modules/auth/bindings/bulk_upload_binding.dart';
import '../modules/auth/bindings/dashboard_binding.dart';
import '../modules/auth/bindings/employee_list_binding.dart';
import '../modules/auth/bindings/add_product_binding.dart';
import '../modules/auth/bindings/edit_product_binding.dart';
import '../modules/auth/bindings/add_employee_binding.dart';
import '../modules/auth/bindings/employee_dashboard_binding.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = '/';

  static final pages = [
    // Public routes (no middleware)
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
    ),

    // Guest routes (redirect if authenticated)
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.employeeLogin,
      page: () => EmployeeLoginScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const ManagerRegistrationScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.companyCreation,
      page: () => CompanyCreationPage(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.createCompanyScreen,
      page: () => const CreateCompanyScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.managerRegistration,
      page: () => const ManagerRegistrationScreen(),
      middlewares: [GuestMiddleware()],
    ),

    // FIXED: Protected manager routes with lazy bindings
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const ManagerDashboard(),
      binding: DashboardBinding(), // Lazy loading
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addEmployee,
      page: () => AddEmployeeScreen(),
      binding: AddEmployeeBinding(), // Lazy loading
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductScreen(),
      binding: AddProductBinding(), // Lazy loading
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => EditProductScreen(),
      binding: EditProductBinding(), // Already had lazy loading
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.managerProfile,
      page: () => ManagerProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.employeeList,
      page: () => EmployeeListScreen(),
      binding: EmployeeListBinding(), // Lazy loading
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.bulkUpload,
      page: () => const BulkUploadScreen(),
      binding: BulkUploadBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // FIXED: Protected employee routes with lazy bindings - NEW MODULAR DASHBOARD
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: () => const EmployeeDashboard(), // Using new modular dashboard
      binding: EmployeeDashboardBinding(), // Lazy loading
      middlewares: [AuthMiddleware()],
    ),

    // About Us route - accessible to both authenticated and non-authenticated users
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsPage(),
    ),
  ];
}
