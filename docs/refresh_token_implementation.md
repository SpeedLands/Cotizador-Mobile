# Implementación de Refresh Token

## Descripción
Este documento explica cómo implementar el sistema de refresh tokens para evitar que los usuarios tengan que volver a iniciar sesión cuando expire su JWT.

## Endpoint de Refresh Token

### URL
```
POST /api/v1/auth/refresh
```

### Request Body
```json
{
  "refresh_token": "string"
}
```

### Response (200 OK)
```json
{
  "token": "nuevo_jwt_token",
  "refresh_token": "nuevo_refresh_token",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "name": "Usuario",
    "email": "usuario@ejemplo.com",
    "is_admin": true
  }
}
```

### Response (401 Unauthorized)
```json
{
  "error": "Invalid refresh token",
  "message": "El refresh token ha expirado o es inválido"
}
```

## Implementación en el Backend

### 1. Modificar el endpoint de login
El endpoint de login debe devolver tanto el JWT como el refresh token:

```php
// En el controlador de autenticación
public function login(Request $request)
{
    // Validar credenciales...
    
    $user = User::where('email', $request->email)->first();
    
    // Generar JWT token (expira en 1 hora)
    $token = JWTAuth::fromUser($user);
    
    // Generar refresh token (expira en 30 días)
    $refreshToken = Str::random(64);
    
    // Guardar refresh token en la base de datos
    $user->refresh_token = hash('sha256', $refreshToken);
    $user->refresh_token_expires_at = now()->addDays(30);
    $user->save();
    
    return response()->json([
        'token' => $token,
        'refresh_token' => $refreshToken,
        'expires_in' => 3600, // 1 hora en segundos
        'user' => $user->only(['id', 'name', 'email', 'is_admin'])
    ]);
}
```

### 2. Crear el endpoint de refresh
```php
public function refresh(Request $request)
{
    $request->validate([
        'refresh_token' => 'required|string'
    ]);
    
    $hashedToken = hash('sha256', $request->refresh_token);
    
    $user = User::where('refresh_token', $hashedToken)
                ->where('refresh_token_expires_at', '>', now())
                ->first();
    
    if (!$user) {
        return response()->json([
            'error' => 'Invalid refresh token',
            'message' => 'El refresh token ha expirado o es inválido'
        ], 401);
    }
    
    // Generar nuevo JWT token
    $token = JWTAuth::fromUser($user);
    
    // Generar nuevo refresh token
    $newRefreshToken = Str::random(64);
    
    // Actualizar refresh token en la base de datos
    $user->refresh_token = hash('sha256', $newRefreshToken);
    $user->refresh_token_expires_at = now()->addDays(30);
    $user->save();
    
    return response()->json([
        'token' => $token,
        'refresh_token' => $newRefreshToken,
        'expires_in' => 3600,
        'user' => $user->only(['id', 'name', 'email', 'is_admin'])
    ]);
}
```

### 3. Modificar el endpoint de logout
```php
public function logout(Request $request)
{
    $user = auth()->user();
    
    // Invalidar refresh token
    $user->refresh_token = null;
    $user->refresh_token_expires_at = null;
    $user->save();
    
    // Invalidar JWT token
    auth()->logout();
    
    return response()->json([
        'message' => 'Logout exitoso'
    ]);
}
```

## Migración de Base de Datos

Agregar las columnas necesarias para el refresh token:

```php
// En una nueva migración
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('refresh_token')->nullable();
        $table->timestamp('refresh_token_expires_at')->nullable();
    });
}
```

## Rutas

Agregar la ruta del refresh token:

```php
// En routes/api.php
Route::post('/auth/refresh', [AuthController::class, 'refresh']);
```

## Seguridad

### Consideraciones importantes:

1. **Almacenamiento seguro**: Los refresh tokens se almacenan hasheados en la base de datos
2. **Expiración**: Los refresh tokens expiran después de 30 días
3. **Invalidación**: Al hacer logout, se invalida tanto el JWT como el refresh token
4. **Rotación**: Cada vez que se usa un refresh token, se genera uno nuevo
5. **Rate limiting**: Implementar rate limiting en el endpoint de refresh

### Rate Limiting
```php
// En el middleware
Route::post('/auth/refresh', [AuthController::class, 'refresh'])
    ->middleware('throttle:5,1'); // Máximo 5 intentos por minuto
```

## Testing

### Casos de prueba:

1. **Refresh exitoso**: Usar un refresh token válido
2. **Refresh token expirado**: Usar un refresh token que ya expiró
3. **Refresh token inválido**: Usar un refresh token que no existe
4. **Rate limiting**: Intentar hacer muchos refreshes en poco tiempo
5. **Logout**: Verificar que el refresh token se invalida después del logout

## Beneficios

1. **Mejor UX**: Los usuarios no tienen que volver a iniciar sesión frecuentemente
2. **Seguridad**: Los JWT siguen siendo de corta duración
3. **Flexibilidad**: Se puede ajustar la duración de ambos tokens según las necesidades
4. **Control**: Se puede invalidar tokens específicos desde el servidor
