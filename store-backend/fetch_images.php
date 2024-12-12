<?php
header("Content-Type: application/json");

$host = "localhost";
$username = "root";
$password = "";
$database = "mydb";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

$sql = "SELECT id, item_name, TO_BASE64(image_data) as image_data FROM store_items";
$result = $conn->query($sql);

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["status" => "success", "data" => $data]);

$conn->close();
?>
