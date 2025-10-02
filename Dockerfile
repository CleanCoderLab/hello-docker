# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy all local files into the container's /src directory.
# This assumes the Dockerfile is in your solution root, and the project is in a subdirectory called "Hello-Docker".
COPY . .

# Explicitly restore dependencies for the project file.
# This fixes the MSB1003 error by not relying on the current directory.
RUN dotnet restore Hello-Docker.csproj

# Build the application, referencing the project file directly
RUN dotnet build Hello-Docker.csproj -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
# Explicitly publish the application, referencing the project file directly
RUN dotnet publish Hello-Docker.csproj -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

EXPOSE 8080

COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "Hello-Docker.dll"]
