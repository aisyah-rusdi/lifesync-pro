<?php
// Database connection
$host = "localhost";
$user = "root";
$password = "";
$dbname = "lifesync";

$conn = new mysqli($host, $user, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch image data
$id = isset($_GET['id']) ? intval($_GET['id']) : 1; // Default to 1 if no ID is provided
$sql = "SELECT name, points, price, image FROM store_items WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);
$stmt->execute();
$stmt->bind_result($name, $points, $price, $image);
$stmt->fetch();

if ($image) {
    // Output image directly
    header("Content-Type: image/jpg"); // Adjust MIME type as necessary
    echo $image;
} else {
    echo "Image not found.";
}

$stmt->close();
$conn->close();
?>
