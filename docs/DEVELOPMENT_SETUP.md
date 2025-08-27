# Configuración de Desarrollo

## 📋 Prerequisitos

### Software Requerido
- **Flutter SDK**: 3.x o superior
- **Dart SDK**: 3.x o superior
- **IDE**: Android Studio, VS Code, o IntelliJ IDEA
- **Git**: Para control de versiones

### Herramientas Adicionales
- **Android Studio**: Para desarrollo Android
- **Xcode**: Para desarrollo iOS (solo macOS)
- **Chrome**: Para desarrollo web

## ⚙️ Configuración Inicial

### 1. Clonar el Repositorio
```bash
git clone <repository-url>
```

### 2. Instalar Dependencias
```bash
# Instalar dependencias de Flutter
flutter pub get

# Verificar instalación
flutter doctor
```

### 3. Configurar Variables de Entorno

El proyecto utiliza archivos de configuración para diferentes ambientes:

#### Desarrollo (`env_dev.json`)
```json
{
    "ENV": "dev",
    "BASE_URL": "http://XXXX/"
}
```

#### Producción (`env.json`)
```json
{
    "ENV": "prod",
    "BASE_URL": "https://app.silcadev.com/"
}
```

### 4. Configuración del IDE

#### VS Code
Extensiones recomendadas:
- **Flutter**: Soporte completo para Flutter
- **Dart**: Soporte para Dart
- **Bloc**: Snippets para BLoC pattern

#### Android Studio
Plugins recomendados:
- **Flutter Plugin**
- **Dart Plugin**
- **Bloc Plugin**

## 🏃‍♂️ Comandos de Desarrollo

### Ejecutar la Aplicación
```bash
# Desarrollo
flutter run --dart-define-from-file=env_dev.json

# Producción
flutter run --dart-define-from-file=env.json

# Con dispositivo específico
flutter run -d <device-id> --dart-define-from-file=env_dev.json

# Hot reload automático
flutter run --hot
```

### Testing
```bash
# Ejecutar todos los tests
flutter test

# Tests con coverage
flutter test --coverage

### Build y Deployment
```bash
# Build para Android (APK)
flutter build apk --dart-define-from-file=env.json

# Build para Android (AAB)
flutter build appbundle --dart-define-from-file=env.json

# Build para iOS
flutter build ios --dart-define-from-file=env.json

# Build para Web
flutter build web --dart-define-from-file=env.json
```

### Análisis y Calidad de Código
```bash
# Análisis estático
flutter analyze

# Formatear código
dart format .

# Fix automático de problemas
dart fix --apply
```

## 🔧 Configuración de Debugging

### Debug en VS Code
Crear archivo `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Launch development",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--dart-define-from-file",
                "env_dev.json"
            ]
        },
        {
            "name": "Launch production",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--dart-define-from-file",
                "env.json"
            ]
        }
    ]
}
```

## 🎯 Flujo de Desarrollo

### 1. Crear Nueva Feature
```bash
# Crear rama para feature
git checkout -b feature/nueva-funcionalidad

# Crear estructura básica
mkdir lib/features/nueva_funcionalidad
mkdir lib/features/nueva_funcionalidad/presentation
mkdir lib/features/nueva_funcionalidad/domain
mkdir lib/features/nueva_funcionalidad/data
```

### 2. Implementar según Clean Architecture
1. **Domain**: Entidades, use cases, repositorios (interfaces)
2. **Data**: Implementación de repositorios, modelos, datasources
3. **Presentation**: BLoCs, páginas, widgets

### 3. Testing
1. Escribir tests unitarios para use cases
2. Tests de integración para repositorios
3. Tests de widgets para UI

### 4. Documentation
1. Actualizar documentación de feature
2. Agregar comentarios JSDoc/DartDoc
3. Actualizar README si es necesario

## 🐛 Troubleshooting

### Problemas Comunes

#### Error de Dependencias
```bash
# Limpiar caché
flutter clean
flutter pub get

# Actualizar dependencias
flutter pub upgrade
```

#### Problemas de Build
```bash
# Limpiar build
flutter clean

# Rebuild completo
flutter pub get
flutter build <platform>
```

#### Problemas de Hot Reload
```bash
# Restart completo
flutter run --hot
# Presionar 'R' para hot restart
```

### Variables de Debug
```bash
# Verbose output
flutter run --verbose

# Debug de performance
flutter run --profile

# Análisis de memoria
flutter run --enable-memory-profiling
```

## 🔒 Configuración de Seguridad

### Manejo de Secrets
- Nunca commitear archivos de configuración con datos sensibles
- Usar variables de entorno para API keys
- Implementar obfuscación para builds de producción


## 🤝 Mejores Prácticas

### Código
1. Seguir las convenciones de Dart/Flutter
2. Usar análisis estático (flutter analyze)
3. Mantener cobertura de tests > 80%
4. Documentar APIs públicas

### Git
1. Commits descriptivos y atómicos
2. Usar conventional commits
3. Review obligatorio antes de merge
4. Tests passing antes de merge

### Performance
1. Usar `const` constructors cuando sea posible
2. Evitar rebuilds innecesarios
3. Optimizar imágenes y assets
4. Monitorear memoria y CPU