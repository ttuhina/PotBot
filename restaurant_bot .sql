CREATE DATABASE restaurant_bot;
USE restaurant_bot;

CREATE TABLE `menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) DEFAULT NULL,
  `item` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `menus_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `order_type` enum('delivery','pickup') NOT NULL,
  `order_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`order_details`)),
  `total_price` decimal(10,2) NOT NULL,
  `status` enum('pending','paid','confirmed','preparing','ready_for_pickup','out_for_delivery','delivered','completed') DEFAULT 'pending',
  PRIMARY KEY (`order_id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `reservations` (
  `reservation_id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `reservation_date` date NOT NULL,
  `reservation_time` time NOT NULL,
  `special_requests` text DEFAULT NULL,
  `number_of_people` int(11) NOT NULL,
  `table_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `restaurants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `cuisine` varchar(100) NOT NULL,
  `location` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `menu` text DEFAULT NULL,
  `price` enum('affordable','moderate','expensive') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `table_number` int(11) NOT NULL,
  `capacity` int(11) NOT NULL,
  `availability` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `tables_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`review_id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `user_order_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `restaurant_id` int(11) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `user_order_history_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

---------------------------------------------------------------------------------------------------------
--TEST DATA (OPTIONAL, BUT NECESSARY FOR TESTING)
---------------------------------------------------------------------------------------------------------

INSERT INTO `menus` (`restaurant_id`, `item`, `price`, `id`) VALUES
(1, 'Noodles', 200.00, 1),
(1, 'Pasta', 350.00, 2),
(1, 'Butter Chicken', 400.00, 3),
(2, 'Noodles', 200.00, 4),
(2, 'Pasta', 350.00, 5),
(2, 'Butter Chicken', 400.00, 6),
(3, 'Noodles', 200.00, 7),
(3, 'Pasta', 350.00, 8),
(3, 'Butter Chicken', 400.00, 9),
(4, 'Noodles', 200.00, 10),
(4, 'Pasta', 350.00, 11),
(4, 'Butter Chicken', 400.00, 12),
(5, 'Noodles', 200.00, 13),
(5, 'Pasta', 350.00, 14),
(5, 'Butter Chicken', 400.00, 15),
(6, 'Noodles', 200.00, 16),
(6, 'Pasta', 350.00, 17),
(6, 'Butter Chicken', 400.00, 18),
(7, 'Noodles', 200.00, 19),
(7, 'Pasta', 350.00, 20),
(7, 'Butter Chicken', 400.00, 21),
(8, 'Noodles', 200.00, 22),
(8, 'Pasta', 350.00, 23),
(8, 'Butter Chicken', 400.00, 24),
(9, 'Noodles', 200.00, 25),
(9, 'Pasta', 350.00, 26),
(9, 'Butter Chicken', 400.00, 27),
(10, 'Noodles', 200.00, 28),
(10, 'Pasta', 350.00, 29),
(10, 'Butter Chicken', 400.00, 30),
(11, 'Noodles', 200.00, 31),
(11, 'Pasta', 350.00, 32),
(11, 'Butter Chicken', 400.00, 33),
(12, 'Noodles', 200.00, 34),
(12, 'Pasta', 350.00, 35),
(12, 'Butter Chicken', 400.00, 36),
(13, 'Noodles', 200.00, 37),
(13, 'Pasta', 350.00, 38),
(13, 'Butter Chicken', 400.00, 39),
(14, 'Noodles', 200.00, 40),
(14, 'Pasta', 350.00, 41),
(14, 'Butter Chicken', 400.00, 42),
(15, 'Noodles', 200.00, 43),
(15, 'Pasta', 350.00, 44),
(15, 'Butter Chicken', 400.00, 45),
(16, 'Noodles', 200.00, 46),
(16, 'Pasta', 350.00, 47),
(16, 'Butter Chicken', 400.00, 48),
(17, 'Noodles', 200.00, 49),
(17, 'Pasta', 350.00, 50),
(17, 'Butter Chicken', 400.00, 51),
(18, 'Noodles', 200.00, 52),
(18, 'Pasta', 350.00, 53),
(18, 'Butter Chicken', 400.00, 54),
(19, 'Noodles', 200.00, 55),
(19, 'Pasta', 350.00, 56),
(19, 'Butter Chicken', 400.00, 57),
(20, 'Noodles', 200.00, 58),
(20, 'Pasta', 350.00, 59),
(20, 'Butter Chicken', 400.00, 60),
(21, 'Noodles', 200.00, 61),
(21, 'Pasta', 350.00, 62),
(21, 'Butter Chicken', 400.00, 63),
(22, 'Noodles', 200.00, 64),
(22, 'Pasta', 350.00, 65),
(22, 'Butter Chicken', 400.00, 66),
(23, 'Noodles', 200.00, 67),
(23, 'Pasta', 350.00, 68),
(23, 'Butter Chicken', 400.00, 69),
(24, 'Noodles', 200.00, 70),
(24, 'Pasta', 350.00, 71),
(24, 'Butter Chicken', 400.00, 72),
(25, 'Noodles', 200.00, 73),
(25, 'Pasta', 350.00, 74),
(25, 'Butter Chicken', 400.00, 75);


INSERT INTO `restaurants` (`id`, `name`, `cuisine`, `location`, `description`, `menu`, `price`) VALUES
(1, 'Golden Dragon', 'Chinese', 'C-Scheme', 'A cozy place offering authentic Chinese dishes.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(2, 'Red Lantern', 'Chinese', 'Malviya Nagar', 'Known for its delicious dim sum and stir-fries.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(3, 'Dragons Breath', 'Chinese', 'Vaishali Nagar', 'High-end dining with gourmet Chinese cuisine.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(4, 'Casa Bonita', 'Mexican', 'C-Scheme', 'Casual Mexican dining with vibrant flavors.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(5, 'El Toro', 'Mexican', 'Malviya Nagar', 'A modern take on traditional Mexican dishes.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(6, 'Pablos Cantina', 'Mexican', 'Vaishali Nagar', 'Luxury dining with an extensive tequila selection.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(7, 'Bangkok Street', 'Thai', 'C-Scheme', 'Street-style Thai food that’s full of flavor.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(8, 'Lotus Thai', 'Thai', 'Malviya Nagar', 'Elegant setting offering a blend of Thai classics.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'affordable'),
(9, 'Siam Sizzler', 'Thai', 'Vaishali Nagar', 'High-end Thai cuisine with a contemporary twist.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(10, 'Maharajas Delight', 'Indian', 'C-Scheme', 'Traditional Indian dishes with a royal touch.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(11, 'Spice Route', 'Indian', 'Malviya Nagar', 'A journey through India’s diverse culinary landscape.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(12, 'Nawabs Court', 'Indian', 'Vaishali Nagar', 'Opulent dining experience with royal Indian flavors.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(13, 'Pasta Fiesta', 'Italian', 'C-Scheme', 'Authentic Italian pasta dishes for everyday dining.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(14, 'Bella Italia', 'Italian', 'Malviya Nagar', 'Classic Italian cuisine in a cozy atmosphere.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(15, 'Tuscan Table', 'Italian', 'Vaishali Nagar', 'Fine dining with a touch of Tuscan elegance.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(16, 'Sakura Sushi', 'Japanese', 'C-Scheme', 'Fresh and affordable sushi in a vibrant setting.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(17, 'Tokyo Dine', 'Japanese', 'Malviya Nagar', 'A modern take on Japanese dining.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'moderate'),
(18, 'Zen Garden', 'Japanese', 'Vaishali Nagar', 'Luxury Japanese cuisine with a serene ambiance.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(19, 'Olive Tree', 'Mediterranean', 'C-Scheme', 'Healthy and flavorful Mediterranean dishes.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(20, 'The Greek House', 'Mediterranean', 'Malviya Nagar', 'Experience the tastes of the Mediterranean.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(21, 'Byzantine', 'Mediterranean', 'Vaishali Nagar', 'High-end dining with Mediterranean flair.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(22, 'Le Bistro', 'French', 'C-Scheme', 'Casual French dining with a cozy atmosphere.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(23, 'Cafe Paris', 'French', 'Malviya Nagar', 'Authentic French cuisine with a modern twist.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(24, 'Chateau Noir', 'French', 'Vaishali Nagar', 'Elegant French dining with gourmet dishes.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(25, 'Burger Joint', 'American', 'C-Scheme', 'Delicious burgers and fries in a casual setting.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(26, 'Diner Dash', 'American', 'Malviya Nagar', 'Classic American diner with comfort food.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive'),
(27, 'Steakhouse 55', 'American', 'Vaishali Nagar', 'Premium steaks and upscale American cuisine.', 'https://i.pinimg.com/564x/7a/86/47/7a8647c7d06419c3b57d08ee21cd6ed0.jpg', 'expensive');


INSERT INTO `reviews` (`review_id`, `restaurant_id`, `username`, `review`, `rating`, `review_date`) VALUES
(1, 1, 'Emily Smith', 'Golden Dragon offers a great variety of traditional Chinese dishes. The ambiance is cozy and service is prompt.', 5, '2024-07-12 17:16:28'),
(2, 1, 'James Johnson', 'I enjoyed the dim sum at Golden Dragon, especially the dumplings. It\'s a go-to place for authentic Chinese food.', 4, '2024-07-12 17:16:28'),
(3, 1, 'Sarah Brown', 'The food was good but the service could have been better. Overall, a decent experience.', 3, '2024-07-12 17:16:28'),
(4, 1, 'Michael Wilson', 'I found the food quality inconsistent. Some dishes were excellent while others were disappointing.', 2, '2024-07-12 17:16:28'),
(5, 1, 'Jennifer Martinez', 'Unfortunately, my experience at Golden Dragon was disappointing. The food was cold and lacked flavor.', 1, '2024-07-12 17:16:28'),
(6, 2, 'Daniel Thompson', 'Red Lantern has a lovely ambiance and the dim sum was delicious. Highly recommended!', 5, '2024-07-12 17:16:28'),
(7, 2, 'Olivia Davis', 'The food at Red Lantern is good, but the service was a bit slow. Overall, a pleasant dining experience.', 4, '2024-07-12 17:16:28'),
(8, 2, 'William Rodriguez', 'I expected more from Red Lantern. The dishes were average and didn’t quite meet my expectations.', 3, '2024-07-12 17:16:28'),
(9, 2, 'Emma Garcia', 'Disappointed with the portion size at Red Lantern. The flavors were okay but not outstanding.', 2, '2024-07-12 17:16:28'),
(10, 2, 'Alexander Wilson', 'My experience at Red Lantern was disappointing. The food was cold and the service was slow.', 1, '2024-07-12 17:16:28'),
(11, 3, 'Sophia Anderson', 'Dragon’s Breath offers a luxurious dining experience with high-quality Chinese cuisine. Perfect for special occasions.', 5, '2024-07-12 17:16:28'),
(12, 3, 'Matthew Moore', 'The food at Dragon’s Breath is exquisite and the service is impeccable. Highly recommend for fine dining.', 5, '2024-07-12 17:16:28'),
(13, 3, 'Ava Taylor', 'While the food was good at Dragon’s Breath, the prices were a bit steep for what you get.', 3, '2024-07-12 17:16:28'),
(14, 3, 'Noah White', 'Disappointed with the portion sizes at Dragon’s Breath. The flavors were good but portions were too small.', 2, '2024-07-12 17:16:28'),
(15, 3, 'Ella Lopez', 'My experience at Dragon’s Breath was disappointing. The food did not justify the high prices.', 1, '2024-07-12 17:16:28'),
(16, 16, 'Sophia Johnson', 'Sakura Sushi has a great selection of sushi rolls and sashimi. Fresh and delicious!', 5, '2024-07-12 17:16:28'),
(17, 16, 'Liam Brown', 'The ambiance at Sakura Sushi is vibrant. A good place for sushi lovers.', 4, '2024-07-12 17:16:28'),
(18, 16, 'Ava Martin', 'Disappointed with the sushi quality at Sakura Sushi. It didn\'t taste fresh.', 2, '2024-07-12 17:16:28'),
(19, 16, 'Noah Davis', 'Service was slow and the sushi rolls were not well-prepared. Disappointing experience.', 2, '2024-07-12 17:16:28'),
(20, 16, 'Ella Wilson', 'Would not recommend Sakura Sushi. Overpriced for what you get.', 1, '2024-07-12 17:16:28'),
(21, 7, 'Sophia Anderson', 'Bangkok Street serves delicious Thai street food. The flavors are authentic and satisfying.', 5, '2024-07-12 17:16:28'),
(22, 7, 'Matthew Moore', 'The dishes at Bangkok Street are flavorful and well-prepared. Highly recommended for Thai food lovers.', 4, '2024-07-12 17:16:28'),
(23, 7, 'Ava Taylor', 'Bangkok Street was decent, but the flavors were not as bold as expected from Thai cuisine.', 3, '2024-07-12 17:16:28'),
(24, 7, 'Noah White', 'The food was mediocre at Bangkok Street. Not worth the hype.', 2, '2024-07-12 17:16:28'),
(25, 7, 'Ella Lopez', 'I did not enjoy my meal at Bangkok Street. The food lacked authenticity and flavor.', 1, '2024-07-12 17:16:28'),
(26, 8, 'Sophia Johnson', 'Lotus Thai offers a pleasant dining experience with a variety of Thai dishes. Enjoyed the ambiance.', 5, '2024-07-12 17:16:28'),
(27, 8, 'Liam Brown', 'The food quality at Lotus Thai was good, but the service could have been better.', 4, '2024-07-12 17:16:28'),
(28, 8, 'Ava Martin', 'Lotus Thai was okay, but nothing extraordinary. Expected more from the reviews.', 3, '2024-07-12 17:16:28'),
(29, 8, 'Noah Davis', 'Food at Lotus Thai was disappointing. The dishes were bland and uninspiring.', 2, '2024-07-12 17:16:28'),
(30, 8, 'Ella Wilson', 'My experience at Lotus Thai was not great. The food lacked authenticity and flavor.', 1, '2024-07-12 17:16:28'),
(31, 10, 'Daniel Thompson', 'Maharaja’s Delight serves delicious Indian food with authentic flavors. Loved the ambiance!', 5, '2024-07-12 17:16:28'),
(32, 10, 'Olivia Davis', 'The food at Maharaja’s Delight was flavorful and satisfying. Highly recommended for Indian cuisine.', 4, '2024-07-12 17:16:28'),
(33, 10, 'William Rodriguez', 'Maharaja’s Delight was good, but the service was slow. Overall, a decent dining experience.', 3, '2024-07-12 17:16:28'),
(34, 10, 'Emma Garcia', 'Disappointed with the portion size at Maharaja’s Delight. The flavors were okay but not outstanding.', 2, '2024-07-12 17:16:28'),
(35, 10, 'Alexander Wilson', 'My experience at Maharaja’s Delight was disappointing. The food was cold and the service was slow.', 1, '2024-07-12 17:16:28'),
(36, 13, 'Sophia Anderson', 'Pasta Fiesta serves delicious Italian pasta dishes. The sauces are rich and flavorful.', 5, '2024-07-12 17:16:28'),
(37, 13, 'Matthew Moore', 'Enjoyed the variety of pasta dishes at Pasta Fiesta. A great place for Italian food.', 4, '2024-07-12 17:16:28'),
(38, 13, 'Ava Taylor', 'The pasta at Pasta Fiesta was good, but the service was slow. Overall, a decent experience.', 3, '2024-07-12 17:16:28'),
(39, 13, 'Noah White', 'Disappointed with the portion size at Pasta Fiesta. The flavors were okay but not outstanding.', 2, '2024-07-12 17:16:28'),
(40, 13, 'Ella Lopez', 'My experience at Pasta Fiesta was disappointing. The food lacked authenticity and flavor.', 1, '2024-07-12 17:16:28'),
(41, 14, 'Daniel Thompson', 'Bella Italia offers a cozy atmosphere with delicious Italian dishes. Loved the pizzas!', 5, '2024-07-12 17:16:28'),
(42, 14, 'Olivia Davis', 'The food at Bella Italia was good, but the service was a bit slow. Overall, a pleasant dining experience.', 4, '2024-07-12 17:16:28'),
(43, 14, 'William Rodriguez', 'Bella Italia was okay, but nothing extraordinary. Expected more from the reviews.', 3, '2024-07-12 17:16:28'),
(44, 14, 'Emma Garcia', 'Food at Bella Italia was disappointing. The dishes were bland and uninspiring.', 2, '2024-07-12 17:16:28'),
(45, 14, 'Alexander Wilson', 'Would not recommend Bella Italia. Overpriced for what you get.', 1, '2024-07-12 17:16:28'),
(46, 15, 'Sophia Johnson', 'Tuscan Table offers fine dining with a touch of Tuscan elegance. The food was exquisite.', 5, '2024-07-12 17:16:28'),
(47, 15, 'Liam Brown', 'The ambiance at Tuscan Table is lovely. A good place for special occasions.', 4, '2024-07-12 17:16:28'),
(48, 15, 'Ava Martin', 'Tuscan Table was decent, but the flavors were not as bold as expected from Italian cuisine.', 3, '2024-07-12 17:16:28'),
(49, 15, 'Noah Davis', 'The food at Tuscan Table was disappointing. It didn\'t meet my expectations.', 2, '2024-07-12 17:16:28'),
(50, 15, 'Ella Wilson', 'My experience at Tuscan Table was disappointing. The food was overpriced for the quality.', 1, '2024-07-12 17:16:28'),
(51, 19, 'Sophia Anderson', 'Olive Tree offers healthy and flavorful Mediterranean dishes. Loved the hummus and falafel!', 5, '2024-07-12 17:16:28'),
(52, 19, 'Matthew Moore', 'The food at Olive Tree was fresh and delicious. Great place for Mediterranean cuisine.', 4, '2024-07-12 17:16:28'),
(53, 19, 'Ava Taylor', 'Olive Tree was decent, but the portion sizes were smaller than expected.', 3, '2024-07-12 17:16:28'),
(54, 19, 'Noah White', 'The flavors at Olive Tree were okay, but the food was not as satisfying.', 2, '2024-07-12 17:16:28'),
(55, 19, 'Ella Lopez', 'Disappointed with the food quality at Olive Tree. It did not meet my expectations.', 1, '2024-07-12 17:16:28'),
(56, 20, 'Daniel Thompson', 'The Greek House serves authentic Mediterranean cuisine with a warm ambiance. Enjoyed the moussaka!', 5, '2024-07-12 17:16:28'),
(57, 20, 'Olivia Davis', 'The food at The Greek House was flavorful and reminded me of Greece. Highly recommended.', 4, '2024-07-12 17:16:28'),
(58, 20, 'William Rodriguez', 'The Greek House was okay, but the service was slow. Expected better.', 3, '2024-07-12 17:16:28'),
(59, 20, 'Emma Garcia', 'Disappointed with the portion size at The Greek House. The food was average.', 2, '2024-07-12 17:16:28'),
(60, 20, 'Alexander Wilson', 'My experience at The Greek House was disappointing. The food lacked authenticity.', 1, '2024-07-12 17:16:28'),
(61, 22, 'Sophia Johnson', 'Le Bistro offers a cozy French dining experience with delicious dishes. Loved the atmosphere!', 5, '2024-07-12 17:16:28'),
(62, 22, 'Liam Brown', 'The food quality at Le Bistro was good, but the service could have been better.', 4, '2024-07-12 17:16:28'),
(63, 22, 'Ava Martin', 'Le Bistro was okay, but the flavors were not as bold as expected from French cuisine.', 3, '2024-07-12 17:16:28'),
(64, 22, 'Noah Davis', 'The food at Le Bistro was disappointing. It didn\'t meet my expectations.', 2, '2024-07-12 17:16:28'),
(65, 22, 'Ella Wilson', 'My experience at Le Bistro was disappointing. The food was overpriced for the quality.', 1, '2024-07-12 17:16:28'),
(71, 17, 'Daniel Thompson', 'Tokyo Dine offers a modern take on Japanese cuisine. The ambiance is inviting.', 5, '2024-07-12 17:16:28'),
(72, 17, 'Olivia Davis', 'The food at Tokyo Dine was good, but the portions were smaller than expected.', 4, '2024-07-12 17:16:28'),
(73, 17, 'William Rodriguez', 'Tokyo Dine was okay, but the sushi rolls were not as fresh as I hoped.', 3, '2024-07-12 17:16:28'),
(74, 17, 'Emma Garcia', 'Disappointed with the service at Tokyo Dine. The food was mediocre.', 2, '2024-07-12 17:16:28'),
(75, 17, 'Alexander Wilson', 'My experience at Tokyo Dine was disappointing. The food quality did not meet expectations.', 1, '2024-07-12 17:16:28'),
(76, 18, 'Sophia Johnson', 'Zen Garden offers luxury Japanese cuisine with impeccable presentation. Loved every dish!', 5, '2024-07-12 17:16:28'),
(77, 18, 'Liam Brown', 'The food quality at Zen Garden was exceptional. A great place for a special dinner.', 4, '2024-07-12 17:16:28'),
(78, 18, 'Ava Martin', 'Zen Garden was good, but the service was slow. Expected better.', 3, '2024-07-12 17:16:28'),
(79, 18, 'Noah Davis', 'Disappointed with the portion size at Zen Garden. The food did not justify the price.', 2, '2024-07-12 17:16:28'),
(80, 18, 'Ella Wilson', 'My experience at Zen Garden was disappointing. The flavors were not as refined as expected.', 1, '2024-07-12 17:16:28'),
(84, 19, 'Noah White', 'The flavors at Olive Tree were okay, but the food was not as satisfying.', 2, '2024-07-12 17:16:28'),
(85, 19, 'Ella Lopez', 'Disappointed with the food quality at Olive Tree. It did not meet my expectations.', 1, '2024-07-12 17:16:28'),
(96, 25, 'Sophia Anderson', 'Burger Joint serves delicious burgers with a variety of toppings. A great place for casual dining.', 5, '2024-07-12 17:16:28'),
(97, 25, 'Matthew Moore', 'The burgers at Burger Joint were tasty, but the fries were a bit undercooked.', 4, '2024-07-12 17:16:28'),
(98, 25, 'Ava Taylor', 'Burger Joint was okay, but the service was slow. Expected better for a quick meal.', 3, '2024-07-12 17:16:28'),
(99, 25, 'Noah White', 'Disappointed with the burger quality at Burger Joint. It was dry and lacked flavor.', 2, '2024-07-12 17:16:28'),
(100, 25, 'Ella Lopez', 'My experience at Burger Joint was disappointing. The food did not meet my expectations.', 1, '2024-07-12 17:16:28'),
(101, 26, 'Daniel Thompson', 'Diner Dash offers classic American diner food with a nostalgic feel. Enjoyed the milkshakes!', 5, '2024-07-12 17:16:28'),
(102, 26, 'Olivia Davis', 'The food at Diner Dash was good, but the service was slow. A decent place for comfort food.', 4, '2024-07-12 17:16:28'),
(103, 26, 'William Rodriguez', 'Diner Dash was okay, but the portions were smaller than expected. Not the best value.', 3, '2024-07-12 17:16:28'),
(104, 26, 'Emma Garcia', 'Disappointed with the quality of food at Diner Dash. It was greasy and not well-prepared.', 2, '2024-07-12 17:16:28'),
(105, 26, 'Alexander Wilson', 'My experience at Diner Dash was disappointing. The food did not justify the price.', 1, '2024-07-12 17:16:28'),
(106, 27, 'Sophia Johnson', 'Steakhouse 55 offers premium steaks and a sophisticated dining experience. The steaks were cooked perfectly.', 5, '2024-07-12 17:16:28'),
(107, 27, 'Liam Brown', 'The food quality at Steakhouse 55 was excellent. A great place for steak lovers.', 4, '2024-07-12 17:16:28'),
(108, 27, 'Ava Martin', 'Steakhouse 55 was good, but the service was a bit slow. Expected better for the price.', 3, '2024-07-12 17:16:28'),
(109, 27, 'Noah Davis', 'Disappointed with the portion size at Steakhouse 55. The steaks were good but not worth the high price.', 2, '2024-07-12 17:16:28'),
(110, 27, 'Ella Wilson', 'My experience at Steakhouse 55 was disappointing. The steaks were overcooked and tough.', 1, '2024-07-12 17:16:28'),
(111, 4, 'Sophia Anderson', 'Casa Bonita offers casual Mexican dining with vibrant flavors. Loved the tacos!', 5, '2024-07-12 17:16:28'),
(112, 4, 'Matthew Moore', 'The food at Casa Bonita was flavorful and reminded me of Mexico. Highly recommended.', 4, '2024-07-12 17:16:28'),
(113, 4, 'Ava Taylor', 'Casa Bonita was okay, but the service was slow. Expected better.', 3, '2024-07-12 17:16:28'),
(114, 4, 'Noah White', 'Disappointed with the portion size at Casa Bonita. The food was average.', 2, '2024-07-12 17:16:28'),
(115, 4, 'Ella Lopez', 'My experience at Casa Bonita was disappointing. The food did not meet my expectations.', 1, '2024-07-12 17:16:28'),
(116, 5, 'Daniel Thompson', 'El Toro offers a modern take on Mexican dishes. Enjoyed the tacos and guacamole!', 5, '2024-07-12 17:16:28'),
(117, 5, 'Olivia Davis', 'The food at El Toro was good, but the service could have been better.', 4, '2024-07-12 17:16:28'),
(118, 5, 'William Rodriguez', 'El Toro was okay, but the flavors were not as bold as expected from Mexican cuisine.', 3, '2024-07-12 17:16:28'),
(119, 5, 'Emma Garcia', 'Disappointed with the food quality at El Toro. It did not meet my expectations.', 2, '2024-07-12 17:16:28'),
(120, 5, 'Alexander Wilson', 'My experience at El Toro was disappointing. The food was overpriced for the quality.', 1, '2024-07-12 17:16:28'),
(121, 6, 'Sophia Johnson', 'Pablo’s Cantina offers luxury Mexican dining with an extensive tequila selection. Loved the ambiance!', 5, '2024-07-12 17:16:28'),
(122, 6, 'Liam Brown', 'The food quality at Pablo’s Cantina was excellent. A great place for a special night out.', 4, '2024-07-12 17:16:28'),
(123, 6, 'Ava Martin', 'Pablo’s Cantina was good, but the service was slow. Expected better for the price.', 3, '2024-07-12 17:16:28'),
(124, 6, 'Noah Davis', 'Disappointed with the portion size at Pablo’s Cantina. The food was good but not worth the high price.', 2, '2024-07-12 17:16:28'),
(125, 6, 'Ella Wilson', 'My experience at Pablo’s Cantina was disappointing. The food did not justify the price.', 1, '2024-07-12 17:16:28'),
(126, 11, 'john_doe', 'Excellent food and great service!', 5, '2024-07-12 19:10:24'),
(127, 11, 'jane_smith', 'Loved the ambiance and the dishes were delicious.', 4, '2024-07-12 19:10:24'),
(128, 11, 'bob_johnson', 'A wonderful experience overall.', 4, '2024-07-12 19:10:24'),
(129, 12, 'alice_williams', 'Amazing flavors and friendly staff!', 5, '2024-07-12 19:10:24'),
(130, 12, 'charlie_brown', 'Great place for a family dinner.', 4, '2024-07-12 19:10:24'),
(131, 12, 'dana_scarlett', 'Enjoyed every bite, will come again.', 4, '2024-07-12 19:10:24'),
(132, 21, 'eve_black', 'Fantastic food and cozy atmosphere.', 5, '2024-07-12 19:10:24'),
(133, 21, 'frank_white', 'Really enjoyed the meals, highly recommend!', 4, '2024-07-12 19:10:24'),
(134, 21, 'grace_green', 'Excellent dining experience.', 4, '2024-07-12 19:10:24'),
(135, 24, 'hank_blue', 'Wonderful flavors and great hospitality.', 5, '2024-07-12 19:10:24'),
(136, 24, 'ivy_yellow', 'Loved the food, very well prepared.', 4, '2024-07-12 19:10:24'),
(137, 24, 'jack_orange', 'A delightful dining experience.', 4, '2024-07-12 19:10:24'),
(138, 11, 'kate_purple', 'The food was cold and bland.', 2, '2024-07-12 19:10:24'),
(139, 11, 'liam_red', 'Service was slow and inattentive.', 1, '2024-07-12 19:10:24'),
(140, 12, 'mike_gray', 'Overpriced for the quality offered.', 2, '2024-07-12 19:10:24'),
(141, 12, 'nina_brown', 'Food was undercooked and lacked flavor.', 1, '2024-07-12 19:10:24'),
(142, 21, 'oscar_black', 'Unfriendly staff and poor hygiene.', 2, '2024-07-12 19:10:24'),
(143, 21, 'peter_white', 'Food took too long to arrive and was tasteless.', 1, '2024-07-12 19:10:24'),
(144, 24, 'quinn_green', 'Disappointing experience, won’t come back.', 2, '2024-07-12 19:10:24'),
(145, 24, 'rachel_blue', 'The worst dining experience I have had.', 1, '2024-07-12 19:10:24');


INSERT INTO `tables` (`id`, `restaurant_id`, `table_number`, `capacity`, `availability`) VALUES
(1, 1, 1, 1, 1),
(2, 1, 2, 2, 1),
(3, 1, 3, 3, 1),
(4, 1, 4, 4, 1),
(5, 1, 5, 5, 1),
(6, 2, 1, 1, 1),
(7, 2, 2, 2, 1),
(8, 2, 3, 3, 1),
(9, 2, 4, 4, 1),
(10, 2, 5, 5, 1),
(11, 3, 1, 1, 1),
(12, 3, 2, 2, 1),
(13, 3, 3, 3, 1),
(14, 3, 4, 4, 1),
(15, 3, 5, 5, 1),
(16, 4, 1, 1, 1),
(17, 4, 2, 2, 1),
(18, 4, 3, 3, 1),
(19, 4, 4, 4, 1),
(20, 4, 5, 5, 1),
(21, 5, 1, 1, 1),
(22, 5, 2, 2, 1),
(23, 5, 3, 3, 1),
(24, 5, 4, 4, 1),
(25, 5, 5, 5, 1),
(26, 6, 1, 1, 1),
(27, 6, 2, 2, 1),
(28, 6, 3, 3, 1),
(29, 6, 4, 4, 1),
(30, 6, 5, 5, 1),
(31, 7, 1, 1, 1),
(32, 7, 2, 2, 1),
(33, 7, 3, 3, 1),
(34, 7, 4, 4, 1),
(35, 7, 5, 5, 1),
(36, 8, 1, 1, 1),
(37, 8, 2, 2, 1),
(38, 8, 3, 3, 1),
(39, 8, 4, 4, 1),
(40, 8, 5, 5, 1),
(41, 9, 1, 1, 1),
(42, 9, 2, 2, 1),
(43, 9, 3, 3, 1),
(44, 9, 4, 4, 1),
(45, 9, 5, 5, 1),
(46, 10, 1, 1, 1),
(47, 10, 2, 2, 1),
(48, 10, 3, 3, 1),
(49, 10, 4, 4, 1),
(50, 10, 5, 5, 1),
(51, 11, 1, 1, 0),
(52, 11, 2, 2, 1),
(53, 11, 3, 3, 1),
(54, 11, 4, 4, 1),
(55, 11, 5, 5, 1),
(56, 12, 1, 1, 1),
(57, 12, 2, 2, 1),
(58, 12, 3, 3, 1),
(59, 12, 4, 4, 1),
(60, 12, 5, 5, 1),
(61, 13, 1, 1, 1),
(62, 13, 2, 2, 1),
(63, 13, 3, 3, 1),
(64, 13, 4, 4, 1),
(65, 13, 5, 5, 1),
(66, 14, 1, 1, 1),
(67, 14, 2, 2, 1),
(68, 14, 3, 3, 1),
(69, 14, 4, 4, 1),
(70, 14, 5, 5, 1),
(71, 15, 1, 1, 1),
(72, 15, 2, 2, 1),
(73, 15, 3, 3, 1),
(74, 15, 4, 4, 1),
(75, 15, 5, 5, 1),
(76, 16, 1, 1, 1),
(77, 16, 2, 2, 1),
(78, 16, 3, 3, 1),
(79, 16, 4, 4, 0),
(80, 16, 5, 5, 0),
(81, 17, 1, 1, 1),
(82, 17, 2, 2, 1),
(83, 17, 3, 3, 1),
(84, 17, 4, 4, 1),
(85, 17, 5, 5, 1),
(86, 18, 1, 1, 1),
(87, 18, 2, 2, 1),
(88, 18, 3, 3, 1),
(89, 18, 4, 4, 1),
(90, 18, 5, 5, 1),
(91, 19, 1, 1, 1),
(92, 19, 2, 2, 1),
(93, 19, 3, 3, 1),
(94, 19, 4, 4, 1),
(95, 19, 5, 5, 1),
(96, 20, 1, 1, 1),
(97, 20, 2, 2, 1),
(98, 20, 3, 3, 1),
(99, 20, 4, 4, 1),
(100, 20, 5, 5, 1),
(101, 21, 1, 1, 1),
(102, 21, 2, 2, 1),
(103, 21, 3, 3, 1),
(104, 21, 4, 4, 1),
(105, 21, 5, 5, 1),
(106, 22, 1, 1, 1),
(107, 22, 2, 2, 1),
(108, 22, 3, 3, 1),
(109, 22, 4, 4, 1),
(110, 22, 5, 5, 1),
(111, 23, 1, 1, 1),
(112, 23, 2, 2, 1),
(113, 23, 3, 3, 1),
(114, 23, 4, 4, 1),
(115, 23, 5, 5, 1),
(116, 24, 1, 1, 1),
(117, 24, 2, 2, 0),
(118, 24, 3, 3, 1),
(119, 24, 4, 4, 0),
(120, 24, 5, 5, 1),
(121, 25, 1, 1, 1),
(122, 25, 2, 2, 1),
(123, 25, 3, 3, 1),
(124, 25, 4, 4, 1),
(125, 25, 5, 5, 1),
(126, 26, 1, 1, 1),
(127, 26, 2, 2, 1),
(128, 26, 3, 3, 1),
(129, 26, 4, 4, 1),
(130, 26, 5, 5, 1),
(131, 27, 1, 1, 1),
(132, 27, 2, 2, 1),
(133, 27, 3, 3, 1),
(134, 27, 4, 4, 1),
(135, 27, 5, 5, 1);
COMMIT;
