-- Create the database
CREATE DATABASE IF NOT EXISTS restaurant_bot;
USE restaurant_bot;

-- Create the 'users' table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    date_of_birth DATE
);

-- Create the 'restaurants' table
CREATE TABLE IF NOT EXISTS restaurants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cuisine VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT,
    menu TEXT
);

-- Create the 'menus' table
CREATE TABLE IF NOT EXISTS menus (
    restaurant_id INT,
    item VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Create the 'reviews' table
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    username VARCHAR(100),
    review TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_date DATE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Create the 'orders' table
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    username VARCHAR(100),
    order_type ENUM('delivery', 'pickup') NOT NULL,
    order_details JSON NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Create the 'reservations' table
CREATE TABLE IF NOT EXISTS reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    username VARCHAR(100),
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    special_requests TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);
-- Insert 30 records into the 'restaurants' table without the 'menu' field
INSERT INTO restaurants (name, cuisine, price, location, description)
VALUES
-- Chinese Restaurants
('Golden Dragon', 'Chinese', 'Affordable', 'C-Scheme', 'A cozy place offering authentic Chinese dishes.'),
('Red Lantern', 'Chinese', 'Moderate', 'Malviya Nagar', 'Known for its delicious dim sum and stir-fries.'),
('Dragon’s Breath', 'Chinese', 'Expensive', 'Vaishali Nagar', 'High-end dining with gourmet Chinese cuisine.'),

-- Mexican Restaurants
('Casa Bonita', 'Mexican', 'Affordable', 'C-Scheme', 'Casual Mexican dining with vibrant flavors.'),
('El Toro', 'Mexican', 'Moderate', 'Malviya Nagar', 'A modern take on traditional Mexican dishes.'),
('Pablo’s Cantina', 'Mexican', 'Expensive', 'Vaishali Nagar', 'Luxury dining with an extensive tequila selection.'),

-- Thai Restaurants
('Bangkok Street', 'Thai', 'Affordable', 'C-Scheme', 'Street-style Thai food that’s full of flavor.'),
('Lotus Thai', 'Thai', 'Moderate', 'Malviya Nagar', 'Elegant setting offering a blend of Thai classics.'),
('Siam Sizzler', 'Thai', 'Expensive', 'Vaishali Nagar', 'High-end Thai cuisine with a contemporary twist.'),

-- Indian Restaurants
('Maharaja’s Delight', 'Indian', 'Affordable', 'C-Scheme', 'Traditional Indian dishes with a royal touch.'),
('Spice Route', 'Indian', 'Moderate', 'Malviya Nagar', 'A journey through India’s diverse culinary landscape.'),
('Nawab’s Court', 'Indian', 'Expensive', 'Vaishali Nagar', 'Opulent dining experience with royal Indian flavors.'),

-- Italian Restaurants
('Pasta Fiesta', 'Italian', 'Affordable', 'C-Scheme', 'Authentic Italian pasta dishes for everyday dining.'),
('Bella Italia', 'Italian', 'Moderate', 'Malviya Nagar', 'Classic Italian cuisine in a cozy atmosphere.'),
('Tuscan Table', 'Italian', 'Expensive', 'Vaishali Nagar', 'Fine dining with a touch of Tuscan elegance.'),

-- Japanese Restaurants
('Sakura Sushi', 'Japanese', 'Affordable', 'C-Scheme', 'Fresh and affordable sushi in a vibrant setting.'),
('Tokyo Dine', 'Japanese', 'Moderate', 'Malviya Nagar', 'A modern take on Japanese dining.'),
('Zen Garden', 'Japanese', 'Expensive', 'Vaishali Nagar', 'Luxury Japanese cuisine with a serene ambiance.'),

-- Mediterranean Restaurants
('Olive Tree', 'Mediterranean', 'Affordable', 'C-Scheme', 'Healthy and flavorful Mediterranean dishes.'),
('The Greek House', 'Mediterranean', 'Moderate', 'Malviya Nagar', 'Experience the tastes of the Mediterranean.'),
('Byzantine', 'Mediterranean', 'Expensive', 'Vaishali Nagar', 'High-end dining with Mediterranean flair.'),

-- French Restaurants
('Le Bistro', 'French', 'Affordable', 'C-Scheme', 'Casual French dining with a cozy atmosphere.'),
('Café Paris', 'French', 'Moderate', 'Malviya Nagar', 'Authentic French cuisine with a modern twist.'),
('Château Noir', 'French', 'Expensive', 'Vaishali Nagar', 'Elegant French dining with gourmet dishes.'),

-- American Restaurants
('Burger Joint', 'American', 'Affordable', 'C-Scheme', 'Delicious burgers and fries in a casual setting.'),
('Diner Dash', 'American', 'Moderate', 'Malviya Nagar', 'Classic American diner with comfort food.'),
('Steakhouse 55', 'American', 'Expensive', 'Vaishali Nagar', 'Premium steaks and upscale American cuisine.');

-- Use the restaurant_bot database
USE restaurant_bot;

-- Add the 'review_date' column to the 'reviews' table
ALTER TABLE reviews
ADD COLUMN review_date DATE;

-- Insert specific reviews with real-sounding usernames into the 'reviews' table for each restaurant ID (1-25)
-- Restaurant 1
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(1, 'Emily Smith', 'Golden Dragon offers a great variety of traditional Chinese dishes. The ambiance is cozy and service is prompt.', 5, '2023-01-01'),
(1, 'James Johnson', 'I enjoyed the dim sum at Golden Dragon, especially the dumplings. It\'s a go-to place for authentic Chinese food.', 4, '2023-01-02'),
(1, 'Sarah Brown', 'The food was good but the service could have been better. Overall, a decent experience.', 3, '2023-01-03'),
(1, 'Michael Wilson', 'I found the food quality inconsistent. Some dishes were excellent while others were disappointing.', 2, '2023-01-04'),
(1, 'Jennifer Martinez', 'Unfortunately, my experience at Golden Dragon was disappointing. The food was cold and lacked flavor.', 1, '2023-01-05');

-- Restaurant 2
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(2, 'Daniel Thompson', 'Red Lantern has a lovely ambiance and the dim sum was delicious. Highly recommended!', 5, '2023-01-06'),
(2, 'Olivia Davis', 'The food at Red Lantern is good, but the service was a bit slow. Overall, a pleasant dining experience.', 4, '2023-01-07'),
(2, 'William Rodriguez', 'I expected more from Red Lantern. The dishes were average and didn’t quite meet my expectations.', 3, '2023-01-08'),
(2, 'Emma Garcia', 'Disappointed with the portion size at Red Lantern. The flavors were okay but not outstanding.', 2, '2023-01-09'),
(2, 'Alexander Wilson', 'My experience at Red Lantern was disappointing. The food was cold and the service was slow.', 1, '2023-01-10');

-- Continue inserting reviews for Restaurant 3 to Restaurant 25 in a similar manner...

-- Restaurant 3
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(3, 'Sophia Anderson', 'Dragon’s Breath offers a luxurious dining experience with high-quality Chinese cuisine. Perfect for special occasions.', 5, '2023-01-11'),
(3, 'Matthew Moore', 'The food at Dragon’s Breath is exquisite and the service is impeccable. Highly recommend for fine dining.', 5, '2023-01-12'),
(3, 'Ava Taylor', 'While the food was good at Dragon’s Breath, the prices were a bit steep for what you get.', 3, '2023-01-13'),
(3, 'Noah White', 'Disappointed with the portion sizes at Dragon’s Breath. The flavors were good but portions were too small.', 2, '2023-01-14'),
(3, 'Ella Lopez', 'My experience at Dragon’s Breath was disappointing. The food did not justify the high prices.', 1, '2023-01-15');

-- Continue inserting reviews for Restaurant 4 to Restaurant 25...

-- Restaurant 4
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(4, 'Sophia Johnson', 'Sakura Sushi has a great selection of sushi rolls and sashimi. Fresh and delicious!', 5, '2023-01-16'),
(4, 'Liam Brown', 'The ambiance at Sakura Sushi is vibrant. A good place for sushi lovers.', 4, '2023-01-17'),
(4, 'Ava Martin', 'Disappointed with the sushi quality at Sakura Sushi. It didn\'t taste fresh.', 2, '2023-01-18'),
(4, 'Noah Davis', 'Service was slow and the sushi rolls were not well-prepared. Disappointing experience.', 2, '2023-01-19'),
(4, 'Ella Wilson', 'Would not recommend Sakura Sushi. Overpriced for what you get.', 1, '2023-01-20');

-- Continue inserting reviews for other restaurants (Restaurant 5 to Restaurant 25)...

-- Repeat the INSERT INTO reviews statement structure for each restaurant ID from 5 to 25 following a similar pattern.
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(5, 'Sophia Anderson', 'Bangkok Street serves delicious Thai street food. The flavors are authentic and satisfying.', 5, '2023-01-21'),
(5, 'Matthew Moore', 'The dishes at Bangkok Street are flavorful and well-prepared. Highly recommended for Thai food lovers.', 4, '2023-01-22'),
(5, 'Ava Taylor', 'Bangkok Street was decent, but the flavors were not as bold as expected from Thai cuisine.', 3, '2023-01-23'),
(5, 'Noah White', 'The food was mediocre at Bangkok Street. Not worth the hype.', 2, '2023-01-24'),
(5, 'Ella Lopez', 'I did not enjoy my meal at Bangkok Street. The food lacked authenticity and flavor.', 1, '2023-01-25');

-- Restaurant 6
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(6, 'Sophia Johnson', 'Lotus Thai offers a pleasant dining experience with a variety of Thai dishes. Enjoyed the ambiance.', 5, '2023-01-26'),
(6, 'Liam Brown', 'The food quality at Lotus Thai was good, but the service could have been better.', 4, '2023-01-27'),
(6, 'Ava Martin', 'Lotus Thai was okay, but nothing extraordinary. Expected more from the reviews.', 3, '2023-01-28'),
(6, 'Noah Davis', 'Food at Lotus Thai was disappointing. The dishes were bland and uninspiring.', 2, '2023-01-29'),
(6, 'Ella Wilson', 'My experience at Lotus Thai was not great. The food lacked authenticity and flavor.', 1, '2023-01-30');

-- Continue inserting reviews for Restaurant 7 to Restaurant 25 in a similar manner...

-- Restaurant 7
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(7, 'Daniel Thompson', 'Maharaja’s Delight serves delicious Indian food with authentic flavors. Loved the ambiance!', 5, '2023-02-01'),
(7, 'Olivia Davis', 'The food at Maharaja’s Delight was flavorful and satisfying. Highly recommended for Indian cuisine.', 4, '2023-02-02'),
(7, 'William Rodriguez', 'Maharaja’s Delight was good, but the service was slow. Overall, a decent dining experience.', 3, '2023-02-03'),
(7, 'Emma Garcia', 'Disappointed with the portion size at Maharaja’s Delight. The flavors were okay but not outstanding.', 2, '2023-02-04'),
(7, 'Alexander Wilson', 'My experience at Maharaja’s Delight was disappointing. The food was cold and the service was slow.', 1, '2023-02-05');
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(8, 'Sophia Anderson', 'Pasta Fiesta serves delicious Italian pasta dishes. The sauces are rich and flavorful.', 5, '2023-02-06'),
(8, 'Matthew Moore', 'Enjoyed the variety of pasta dishes at Pasta Fiesta. A great place for Italian food.', 4, '2023-02-07'),
(8, 'Ava Taylor', 'The pasta at Pasta Fiesta was good, but the service was slow. Overall, a decent experience.', 3, '2023-02-08'),
(8, 'Noah White', 'Disappointed with the portion size at Pasta Fiesta. The flavors were okay but not outstanding.', 2, '2023-02-09'),
(8, 'Ella Lopez', 'My experience at Pasta Fiesta was disappointing. The food lacked authenticity and flavor.', 1, '2023-02-10');

-- Restaurant 9
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(9, 'Daniel Thompson', 'Bella Italia offers a cozy atmosphere with delicious Italian dishes. Loved the pizzas!', 5, '2023-02-11'),
(9, 'Olivia Davis', 'The food at Bella Italia was good, but the service was a bit slow. Overall, a pleasant dining experience.', 4, '2023-02-12'),
(9, 'William Rodriguez', 'Bella Italia was okay, but nothing extraordinary. Expected more from the reviews.', 3, '2023-02-13'),
(9, 'Emma Garcia', 'Food at Bella Italia was disappointing. The dishes were bland and uninspiring.', 2, '2023-02-14'),
(9, 'Alexander Wilson', 'Would not recommend Bella Italia. Overpriced for what you get.', 1, '2023-02-15');

-- Continue inserting reviews for Restaurant 10 to Restaurant 25 in a similar manner...

-- Restaurant 10
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(10, 'Sophia Johnson', 'Tuscan Table offers fine dining with a touch of Tuscan elegance. The food was exquisite.', 5, '2023-02-16'),
(10, 'Liam Brown', 'The ambiance at Tuscan Table is lovely. A good place for special occasions.', 4, '2023-02-17'),
(10, 'Ava Martin', 'Tuscan Table was decent, but the flavors were not as bold as expected from Italian cuisine.', 3, '2023-02-18'),
(10, 'Noah Davis', 'The food at Tuscan Table was disappointing. It didn\'t meet my expectations.', 2, '2023-02-19'),
(10, 'Ella Wilson', 'My experience at Tuscan Table was disappointing. The food was overpriced for the quality.', 1, '2023-02-20');
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(11, 'Sophia Anderson', 'Olive Tree offers healthy and flavorful Mediterranean dishes. Loved the hummus and falafel!', 5, '2023-02-21'),
(11, 'Matthew Moore', 'The food at Olive Tree was fresh and delicious. Great place for Mediterranean cuisine.', 4, '2023-02-22'),
(11, 'Ava Taylor', 'Olive Tree was decent, but the portion sizes were smaller than expected.', 3, '2023-02-23'),
(11, 'Noah White', 'The flavors at Olive Tree were okay, but the food was not as satisfying.', 2, '2023-02-24'),
(11, 'Ella Lopez', 'Disappointed with the food quality at Olive Tree. It did not meet my expectations.', 1, '2023-02-25');

-- Restaurant 12
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(12, 'Daniel Thompson', 'The Greek House serves authentic Mediterranean cuisine with a warm ambiance. Enjoyed the moussaka!', 5, '2023-02-26'),
(12, 'Olivia Davis', 'The food at The Greek House was flavorful and reminded me of Greece. Highly recommended.', 4, '2023-02-27'),
(12, 'William Rodriguez', 'The Greek House was okay, but the service was slow. Expected better.', 3, '2023-02-28'),
(12, 'Emma Garcia', 'Disappointed with the portion size at The Greek House. The food was average.', 2, '2023-03-01'),
(12, 'Alexander Wilson', 'My experience at The Greek House was disappointing. The food lacked authenticity.', 1, '2023-03-02');

-- Continue inserting reviews for Restaurant 13 to Restaurant 25 in a similar manner...

-- Restaurant 13
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(13, 'Sophia Johnson', 'Le Bistro offers a cozy French dining experience with delicious dishes. Loved the atmosphere!', 5, '2023-03-03'),
(13, 'Liam Brown', 'The food quality at Le Bistro was good, but the service could have been better.', 4, '2023-03-04'),
(13, 'Ava Martin', 'Le Bistro was okay, but the flavors were not as bold as expected from French cuisine.', 3, '2023-03-05'),
(13, 'Noah Davis', 'The food at Le Bistro was disappointing. It didn\'t meet my expectations.', 2, '2023-03-06'),
(13, 'Ella Wilson', 'My experience at Le Bistro was disappointing. The food was overpriced for the quality.', 1, '2023-03-07');
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(14, 'Sophia Anderson', 'Sakura Sushi offers fresh and delicious sushi. Loved the variety of rolls!', 5, '2023-03-08'),
(14, 'Matthew Moore', 'Enjoyed the sushi at Sakura Sushi. The quality of fish was excellent.', 4, '2023-03-09'),
(14, 'Ava Taylor', 'Sakura Sushi was okay, but the service was slow. Expected better.', 3, '2023-03-10'),
(14, 'Noah White', 'Disappointed with the sushi quality at Sakura Sushi. The rolls were not well-prepared.', 2, '2023-03-11'),
(14, 'Ella Lopez', 'My experience at Sakura Sushi was disappointing. The sushi did not taste fresh.', 1, '2023-03-12');

-- Restaurant 15
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(15, 'Daniel Thompson', 'Tokyo Dine offers a modern take on Japanese cuisine. The ambiance is inviting.', 5, '2023-03-13'),
(15, 'Olivia Davis', 'The food at Tokyo Dine was good, but the portions were smaller than expected.', 4, '2023-03-14'),
(15, 'William Rodriguez', 'Tokyo Dine was okay, but the sushi rolls were not as fresh as I hoped.', 3, '2023-03-15'),
(15, 'Emma Garcia', 'Disappointed with the service at Tokyo Dine. The food was mediocre.', 2, '2023-03-16'),
(15, 'Alexander Wilson', 'My experience at Tokyo Dine was disappointing. The food quality did not meet expectations.', 1, '2023-03-17');

-- Restaurant 16
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(16, 'Sophia Johnson', 'Zen Garden offers luxury Japanese cuisine with impeccable presentation. Loved every dish!', 5, '2023-03-18'),
(16, 'Liam Brown', 'The food quality at Zen Garden was exceptional. A great place for a special dinner.', 4, '2023-03-19'),
(16, 'Ava Martin', 'Zen Garden was good, but the service was slow. Expected better.', 3, '2023-03-20'),
(16, 'Noah Davis', 'Disappointed with the portion size at Zen Garden. The food did not justify the price.', 2, '2023-03-21'),
(16, 'Ella Wilson', 'My experience at Zen Garden was disappointing. The flavors were not as refined as expected.', 1, '2023-03-22');

-- Continue inserting reviews for Restaurant 17 to Restaurant 25 in a similar manner...

-- Restaurant 17
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(17, 'Sophia Anderson', 'Olive Tree offers healthy and flavorful Mediterranean dishes. Loved the hummus and falafel!', 5, '2023-03-23'),
(17, 'Matthew Moore', 'The food at Olive Tree was fresh and delicious. Great place for Mediterranean cuisine.', 4, '2023-03-24'),
(17, 'Ava Taylor', 'Olive Tree was decent, but the portion sizes were smaller than expected.', 3, '2023-03-25'),
(17, 'Noah White', 'The flavors at Olive Tree were okay, but the food was not as satisfying.', 2, '2023-03-26'),
(17, 'Ella Lopez', 'Disappointed with the food quality at Olive Tree. It did not meet my expectations.', 1, '2023-03-27');

-- Restaurant 18
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(18, 'Daniel Thompson', 'The Greek House serves authentic Mediterranean cuisine with a warm ambiance. Enjoyed the moussaka!', 5, '2023-03-28'),
(18, 'Olivia Davis', 'The food at The Greek House was flavorful and reminded me of Greece. Highly recommended.', 4, '2023-03-29'),
(18, 'William Rodriguez', 'The Greek House was okay, but the service was slow. Expected better.', 3, '2023-03-30'),
(18, 'Emma Garcia', 'Disappointed with the portion size at The Greek House. The food was average.', 2, '2023-03-31'),
(18, 'Alexander Wilson', 'My experience at The Greek House was disappointing. The food lacked authenticity.', 1, '2023-04-01');

-- Continue inserting reviews for Restaurant 19 to Restaurant 25 in a similar manner...

-- Restaurant 19
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(19, 'Sophia Johnson', 'Le Bistro offers a cozy French dining experience with delicious dishes. Loved the atmosphere!', 5, '2023-04-02'),
(19, 'Liam Brown', 'The food quality at Le Bistro was good, but the service could have been better.', 4, '2023-04-03'),
(19, 'Ava Martin', 'Le Bistro was okay, but the flavors were not as bold as expected from French cuisine.', 3, '2023-04-04'),
(19, 'Noah Davis', 'The food at Le Bistro was disappointing. It didn\'t meet my expectations.', 2, '2023-04-05'),
(19, 'Ella Wilson', 'My experience at Le Bistro was disappointing. The food was overpriced for the quality.', 1, '2023-04-06');

-- Restaurant 20
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(20, 'Sophia Anderson', 'Burger Joint serves delicious burgers with a variety of toppings. A great place for casual dining.', 5, '2023-04-07'),
(20, 'Matthew Moore', 'The burgers at Burger Joint were tasty, but the fries were a bit undercooked.', 4, '2023-04-08'),
(20, 'Ava Taylor', 'Burger Joint was okay, but the service was slow. Expected better for a quick meal.', 3, '2023-04-09'),
(20, 'Noah White', 'Disappointed with the burger quality at Burger Joint. It was dry and lacked flavor.', 2, '2023-04-10'),
(20, 'Ella Lopez', 'My experience at Burger Joint was disappointing. The food did not meet my expectations.', 1, '2023-04-11');

-- Restaurant 21
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(21, 'Daniel Thompson', 'Diner Dash offers classic American diner food with a nostalgic feel. Enjoyed the milkshakes!', 5, '2023-04-12'),
(21, 'Olivia Davis', 'The food at Diner Dash was good, but the service was slow. A decent place for comfort food.', 4, '2023-04-13'),
(21, 'William Rodriguez', 'Diner Dash was okay, but the portions were smaller than expected. Not the best value.', 3, '2023-04-14'),
(21, 'Emma Garcia', 'Disappointed with the quality of food at Diner Dash. It was greasy and not well-prepared.', 2, '2023-04-15'),
(21, 'Alexander Wilson', 'My experience at Diner Dash was disappointing. The food did not justify the price.', 1, '2023-04-16');

-- Restaurant 22
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(22, 'Sophia Johnson', 'Steakhouse 55 offers premium steaks and a sophisticated dining experience. The steaks were cooked perfectly.', 5, '2023-04-17'),
(22, 'Liam Brown', 'The food quality at Steakhouse 55 was excellent. A great place for steak lovers.', 4, '2023-04-18'),
(22, 'Ava Martin', 'Steakhouse 55 was good, but the service was a bit slow. Expected better for the price.', 3, '2023-04-19'),
(22, 'Noah Davis', 'Disappointed with the portion size at Steakhouse 55. The steaks were good but not worth the high price.', 2, '2023-04-20'),
(22, 'Ella Wilson', 'My experience at Steakhouse 55 was disappointing. The steaks were overcooked and tough.', 1, '2023-04-21');

-- Restaurant 23
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(23, 'Sophia Anderson', 'Casa Bonita offers casual Mexican dining with vibrant flavors. Loved the tacos!', 5, '2023-04-22'),
(23, 'Matthew Moore', 'The food at Casa Bonita was flavorful and reminded me of Mexico. Highly recommended.', 4, '2023-04-23'),
(23, 'Ava Taylor', 'Casa Bonita was okay, but the service was slow. Expected better.', 3, '2023-04-24'),
(23, 'Noah White', 'Disappointed with the portion size at Casa Bonita. The food was average.', 2, '2023-04-25'),
(23, 'Ella Lopez', 'My experience at Casa Bonita was disappointing. The food did not meet my expectations.', 1, '2023-04-26');

-- Restaurant 24
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(24, 'Daniel Thompson', 'El Toro offers a modern take on Mexican dishes. Enjoyed the tacos and guacamole!', 5, '2023-04-27'),
(24, 'Olivia Davis', 'The food at El Toro was good, but the service could have been better.', 4, '2023-04-28'),
(24, 'William Rodriguez', 'El Toro was okay, but the flavors were not as bold as expected from Mexican cuisine.', 3, '2023-04-29'),
(24, 'Emma Garcia', 'Disappointed with the food quality at El Toro. It did not meet my expectations.', 2, '2023-04-30'),
(24, 'Alexander Wilson', 'My experience at El Toro was disappointing. The food was overpriced for the quality.', 1, '2023-05-01');

-- Restaurant 25
INSERT INTO reviews (restaurant_id, username, review, rating, review_date)
VALUES
(25, 'Sophia Johnson', 'Pablo’s Cantina offers luxury Mexican dining with an extensive tequila selection. Loved the ambiance!', 5, '2023-05-02'),
(25, 'Liam Brown', 'The food quality at Pablo’s Cantina was excellent. A great place for a special night out.', 4, '2023-05-03'),
(25, 'Ava Martin', 'Pablo’s Cantina was good, but the service was slow. Expected better for the price.', 3, '2023-05-04'),
(25, 'Noah Davis', 'Disappointed with the portion size at Pablo’s Cantina. The food was good but not worth the high price.', 2, '2023-05-05'),
(25, 'Ella Wilson', 'My experience at Pablo’s Cantina was disappointing. The food did not justify the price.', 1, '2023-05-06');

-- Continue inserting reviews for Restaurant 26 to Restaurant 255 in a similar manner...

-- Repeat the INSERT INTO reviews statement structure for each restaurant ID from 26 to 255 following a similar pattern.
-- Use the restaurant_bot database
USE restaurant_bot;

-- Populate the menus table for restaurant IDs 1 to 25
-- Restaurant ID 1: Chinese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(1, 'Noodles', 200),
(1, 'Pasta', 350),
(1, 'Butter Chicken', 400);

-- Restaurant ID 2: Chinese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(2, 'Noodles', 200),
(2, 'Pasta', 350),
(2, 'Butter Chicken', 400);

-- Restaurant ID 3: Chinese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(3, 'Noodles', 200),
(3, 'Pasta', 350),
(3, 'Butter Chicken', 400);

-- Continue inserting menus for Restaurant IDs 4 to 25 in a similar manner...

-- Restaurant ID 4: Mexican Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(4, 'Noodles', 200),
(4, 'Pasta', 350),
(4, 'Butter Chicken', 400);

-- Restaurant ID 5: Mexican Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(5, 'Noodles', 200),
(5, 'Pasta', 350),
(5, 'Butter Chicken', 400);

-- Continue inserting menus for Restaurant IDs 6 to 25 in a similar manner...

-- Repeat the INSERT INTO menus statement structure for each restaurant ID from 6 to 25 following a similar pattern.

INSERT INTO menus (restaurant_id, item, price)
VALUES
(6, 'Noodles', 200),
(6, 'Pasta', 350),
(6, 'Butter Chicken', 400);

-- Restaurant ID 7: Thai Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(7, 'Noodles', 200),
(7, 'Pasta', 350),
(7, 'Butter Chicken', 400);

-- Restaurant ID 8: Thai Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(8, 'Noodles', 200),
(8, 'Pasta', 350),
(8, 'Butter Chicken', 400);

-- Restaurant ID 9: Indian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(9, 'Noodles', 200),
(9, 'Pasta', 350),
(9, 'Butter Chicken', 400);

-- Restaurant ID 10: Indian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(10, 'Noodles', 200),
(10, 'Pasta', 350),
(10, 'Butter Chicken', 400);

-- Restaurant ID 11: Indian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(11, 'Noodles', 200),
(11, 'Pasta', 350),
(11, 'Butter Chicken', 400);

-- Restaurant ID 12: Italian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(12, 'Noodles', 200),
(12, 'Pasta', 350),
(12, 'Butter Chicken', 400);

-- Restaurant ID 13: Italian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(13, 'Noodles', 200),
(13, 'Pasta', 350),
(13, 'Butter Chicken', 400);

-- Restaurant ID 14: Italian Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(14, 'Noodles', 200),
(14, 'Pasta', 350),
(14, 'Butter Chicken', 400);

-- Restaurant ID 15: Japanese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(15, 'Noodles', 200),
(15, 'Pasta', 350),
(15, 'Butter Chicken', 400);

-- Restaurant ID 16: Japanese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(16, 'Noodles', 200),
(16, 'Pasta', 350),
(16, 'Butter Chicken', 400);

-- Restaurant ID 17: Japanese Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(17, 'Noodles', 200),
(17, 'Pasta', 350),
(17, 'Butter Chicken', 400);

-- Restaurant ID 18: Mediterranean Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(18, 'Noodles', 200),
(18, 'Pasta', 350),
(18, 'Butter Chicken', 400);

-- Restaurant ID 19: Mediterranean Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(19, 'Noodles', 200),
(19, 'Pasta', 350),
(19, 'Butter Chicken', 400);

-- Restaurant ID 20: Mediterranean Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(20, 'Noodles', 200),
(20, 'Pasta', 350),
(20, 'Butter Chicken', 400);

-- Restaurant ID 21: French Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(21, 'Noodles', 200),
(21, 'Pasta', 350),
(21, 'Butter Chicken', 400);

-- Restaurant ID 22: French Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(22, 'Noodles', 200),
(22, 'Pasta', 350),
(22, 'Butter Chicken', 400);

-- Restaurant ID 23: French Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(23, 'Noodles', 200),
(23, 'Pasta', 350),
(23, 'Butter Chicken', 400);

-- Restaurant ID 24: American Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(24, 'Noodles', 200),
(24, 'Pasta', 350),
(24, 'Butter Chicken', 400);

-- Restaurant ID 25: American Cuisine
INSERT INTO menus (restaurant_id, item, price)
VALUES
(25, 'Noodles', 200),
(25, 'Pasta', 350),
(25, 'Butter Chicken', 400);
-- Use the restaurant_bot database
USE restaurant_bot;

-- Update the 'menu' field in the 'restaurants' table with the same URL
UPDATE restaurants
SET menu = 'https://i.pinimg.com/736x/79/e1/49/79e14976c769708df62ad4df16074f4e.jpg';

