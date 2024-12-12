<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database credentials
$host = "localhost";
$username = "root";
$password = "";
$database = "mydb";

// Connect to MySQL
$conn = new mysqli($host, $username, $password, $database);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if an image and item name are sent
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_FILES['image'], $_POST['item_name'])) {
    $itemName = $_POST['item_name'];
    $imageData = file_get_contents($_FILES['image']['tmp_name']); // Get binary data of the image

    $stmt = $conn->prepare("INSERT INTO store_items (item_name, image_data) VALUES (?, ?)");
    $stmt->bind_param("sb", $itemName, $imageData); // 'sb' indicates string and blob
    $stmt->send_long_data(1, $imageData); // Send binary data for the BLOB field

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Image uploaded successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to upload image"]);
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}

$conn->close();
?>
