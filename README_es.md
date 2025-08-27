<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://edsuite.pe/assets/images/logo-dark.png" width="200" alt="Nest Logo" /></a>
</p>
 

  <p align="center">Documentación de la aplicación Edsuite</p>
    <p align="center">

## EDSUITE

## 🎯 Descripción
Aplicación oficial desarrollado en Flutter que forma parte de la plataforma tecnológica de **Escienza**.

## 🚀 Quick Start

### Prerequisitos
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code

### Instalación
```bash
# Clonar el repositorio
git clone <repository-url>

# Instalar dependencias
flutter pub get

# Configurar variables de entorno (copiar desde .env_dev.json y .env.json)
# Configurar env_dev.json y env.json según tu ambiente

# Ejecutar en desarrollo
flutter run --dart-define-from-file=env_dev.json

# Ejecutar en producción
flutter run --dart-define-from-file=env.json
```

## 📱 Características Principales

### ⚙️ Configuración Inicial
- Conexión a servidor mediante IP personalizada
- Validación con código de activación
- Acceso dinámico según tipo de servicio:
1. 🟢 Autoservicio (Cashkeeper)
2. 🟣 Punto de Venta (Niubiz)

### 🔐 Autenticación y Seguridad
- Validación de credenciales en Niubiz con código de usuario
- Manejo seguro de sesiones y estados
- Protección de datos en tiempo real

### 🛠️ Módulo Autoservicio (Cashkeeper)
- Pago directo en terminal de autoservicio
- Integración con Cashkeeper para efectivo
- Operaciones rápidas y seguras sin intervención del personal

### 💳 Módulo Punto de Venta (Niubiz)
- Inicio de sesión con usuario Niubiz
- Procesamiento de pagos con POS Web Niubiz
- Flujo optimizado para atención en app

## 🏗️ Arquitectura

### Patrones de Diseño
- **Domain Driven Design**: Separación clara de responsabilidades
- **BLoC Pattern**: Gestión de estado predecible
- **Repository Pattern**: Abstracción de fuentes de datos

### Estructura de Packages
```
packages/
├── edsuite_common/     # Widgets y utilidades compartidas
└── niubiz/  # Cliente niubiz
```

### Características Técnicas
- Modular package structure para mejor mantenibilidad
- Niubiz client con manejo de canales
- Manejo robusto de errores

## 📚 Documentación

### 📖 Guías de Desarrollo
- [Configuración de Desarrollo](docs/DEVELOPMENT_SETUP.md)
- [Arquitectura del Sistema](docs/ARCHITECTURE.md)

### 🔧 Funcionalidades
- [Auto Servicio](docs/features/documents/DOCUMENTS_MODULE.md)
- [Punto Venta](docs/features/user_management/USER_MANAGEMENT.md)

## � Comandos Útiles

```bash
# Crear un package
flutter create --template=package nombre_del_paquete

# Desarrollo
flutter run --dart-define-from-file=env_dev.json

# Producción
flutter run --dart-define-from-file=env.json

# Tests
flutter test

# Build para Android
flutter build apk --dart-define-from-file=env.json

# Build para iOS
flutter build ios --dart-define-from-file=env.json

# Análisis de código
flutter analyze

# Formatear código
dart format .
```

## 🎨 Recursos

### Fuentes
- **Brunson**: Fuente principal del proyecto
- **Mosvita Sans Serif**: Fuente secundaria (Regular, Bold, Light, SemiBold)

### Iconos
- Icono principal: `assets/icons/escienza_icon.png`

## 🤝 Colaboradores

- 🧑‍💻 Hugo Grados Changanaqui – Full Stack Developer
- 🧑‍💻 Diego Silva Carrión – Full Stack Developer
- 🏢 Equipo Escienza – Ingeniería & Tecnología

## 📄 Licencia

Este proyecto está bajo una licencia **privada**. Todos los derechos reservados a Escienza E.I.R.L.
