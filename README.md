
# PotBot

PotBot simplifies the dining experience by providing a user-friendly chat interface for various restaurant-related services. It helps users find restaurants, browse menus, make reservations, place orders, and more.

## Vision for the project and its web page :

Home Page :

![Home Page](https://github.com/ttuhina/PotBot/blob/main/screenshots/home.png)

Self - Designed logo for the project :

![PotBot logo](https://github.com/ttuhina/PotBot/blob/main/webpage/logo.png)

Sign-Up Page :

![Sign-up Page](https://github.com/ttuhina/PotBot/blob/main/screenshots/signup.png)


## Features

1. **Restaurant Discovery**:
   - Search for restaurants by cuisine, location, or price range.
   - Implemented in `api.js` using the `/api/restaurants` endpoint.
   - Uses MySQL queries to filter restaurants based on cuisine, price, and location.
   - Calculates average ratings for each restaurant.

2. **Menu Exploration**:
   - View digital menus with descriptions and ratings.
   - The `/api/restaurant/menu` endpoint in `api.js` fetches menu information.
   - Menus are stored as image URLs in the `restaurants` table, as an image-based menu is more visually appealing to a user than a  plain text-based menu.

3. **Reservation Management**:
   - Make and manage reservations with special requests.
   - Handled by the `handleReservation`, `processReservationDetails`, and `confirmReservation` functions in `index.js`.
   - Uses the `/api/reservations` endpoint to interact with the database.
   - Checks table availability and assigns tables based on party size.

4. **Ordering System**:
   - Place orders for delivery or pickup directly through the bot, adding or removing items with ease.
   - Implemented through `handleOrder`, `processOrderItems`, and `confirmOrder` functions in `index.js`.
   - Utilizes `/api/orders` and `/api/menu` endpoints for database interactions.
   - Allows adding/removing items and calculates total price accordingly.

5. **Payment Integration**:
   - Secure payment processing within the chat interface.
   - Uses Razorpay API (Only simulated in this version).
   - `initiatePayment` and `confirmPayment` functions in `index.js` handle the payment flow.
   - Integrates with `/api/create-razorpay-order` and `/api/verify-razorpay-payment` endpoints.

6. **Order Tracking**:
   - Real-time updates on order status.
   - Implemented using the `trackOrder` function in `index.js`.
   - Uses the `/api/order-status/:orderId` endpoint to fetch real-time status updates.

7. **Personalized Recommendations**:
   - Suggest restaurants based on user preferences and order history.
   - The `getPersonalizedRecommendations` function in `index.js` handles this feature.
   - Utilizes the `/api/recommendations` endpoint, which queries the `user_order_history` table.

8. **Additional Features**:
   - Customer reviews: Implemented with `/api/reviews/positive` and `/api/reviews/negative` endpoints.
   - Restaurant descriptions: Fetched using the `/api/restaurant/description` endpoint.



## Technology Stack

- Node.js
- Express.js
- MySQL
- Microsoft Bot Framework SDK
- Axios for HTTP requests
- Razorpay for payment processing
- HTML
- CSS
  
## Database Structure
A MySQL database was preffered for this project, as structured tables with dependencies amongst each other were required.
The project uses a MySQL database named `restaurant_bot` with the following table structure:

### Tables

1. **restaurants**
   - Stores basic information about restaurants
   - Fields: id, name, cuisine, location, description, menu, price

2. **menus**
   - Contains menu items for each restaurant
   - Fields: id, restaurant_id, item, price

3. **orders**
   - Tracks customer orders
   - Fields: order_id, restaurant_id, username, order_type, order_details, total_price, status

4. **reservations**
   - Manages reservation details
   - Fields: reservation_id, restaurant_id, username, reservation_date, reservation_time, special_requests, number_of_people, table_number

5. **tables**
   - Keeps track of restaurant tables and their availability
   - Fields: id, restaurant_id, table_number, capacity, availability

6. **reviews**
   - Stores customer reviews for restaurants
   - Fields: review_id, restaurant_id, username, review, rating, review_date

7. **users**
   - Manages user account information
   - Fields: user_id, username, email, password, address, date_of_birth

8. **user_order_history**
   - Tracks user order history for recommendation purposes
   - Fields: id, user_id, restaurant_id, order_date

### Key Features

- Foreign key relationships maintain data integrity between tables
- Use of ENUM types for order status and restaurant price categories
- JSON storage for order details in the `orders` table
- Timestamp fields for tracking review and order dates

### Setup for database

To set up the database:

1. Create a new database named `restaurant_bot` in your MySQL server
2. Execute the SQL commands provided in the `database_setup.sql` file to create the necessary tables and relationships

Note: Ensure that your database connection settings in `api.js` match your local MySQL configuration.

## Setup of project

1. Clone the repository
2. Install dependencies: `npm install`
3. Set up your MySQL database using XAMPP and phpMyAdmin
4. Configure your database connection in `api.js`
5. Start the server: `node index.js` and `node api.js`.
7. Start Apache and MySQL in the XAMPP panel.
8. Install microsoft bot framework sdk from link given below, in references.
9. Open microsoft bot framework sdk and open the bot by going to the link http://localhost:3978/api/messages.
10. Test the bot further.

## API Endpoints

The `api.js` file contains various endpoints for different functionalities:

- `/api/restaurants`: Search restaurants based on criteria
- `/api/reviews`: Fetch positive and negative reviews
- `/api/restaurant/description`: Get restaurant descriptions
- `/api/restaurant/menu`: Retrieve menu information
- `/api/reservations`: Manage reservations
- `/api/orders`: Handle order placement and tracking
- `/api/menu`: Match user-entered items to database menu items
- `/api/recommendations`: Get personalized restaurant recommendations

## Bot Logic

The main bot logic is implemented in `index.js`:

- Handles user interactions and routes requests to appropriate functions
- Manages conversation flow for ordering, reservations, and inquiries
- Integrates with the API endpoints for data retrieval and updates

## Payment Integration

PotBot uses Razorpay for payment processing. It creates payment orders and verifies payments upon confirmation.

## Future Improvements

- Implement user authentication
- Enhance error handling and input validation
- Add more sophisticated natural language processing
- Expand payment options
- Implement a loyalty program

## Resources

- [Bot Framework SDK](https://github.com/microsoft/botframework-sdk)
- [MySQL Tutorial](https://www.w3schools.com/MySQL/default.asp)
- [Node.js Documentation](https://nodejs.org/docs/latest/api)
- [Express.js Tutorial](https://www.tutorialspoint.com/nodejs/nodejs_express_framework.htm)
- [Bot Framework Emulator](https://github.com/Microsoft/BotFramework-Emulator/releases)
- [Azure Language Understanding](https://learn.microsoft.com/en-us/azure/ai-services/language-service/conversational-language-understanding/overview)

## Working Screenshots 
**Introductory messages**:

![Introductory messages](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/intro-message-1.png)
![Introductory messages](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/intro-message-2.png)

**Restaurant recommendation and filtering**:

![](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/restaurant-recommendation.png)

**Menu display**:

![menu display](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/menu-display.png)

**Reviews and description viewing**:

![review/description](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/reviews-description.png)

**Reservation process**:

![reservation](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/reserve-process-1.png)
![reservation](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/reserve-process-2.png)

**Ordering Process**:

![ordering](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/order-process-1.png)
![ordering](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/order-process-2.png)
![ordering](https://github.com/ttuhina/PotBot/blob/main/working%20screenshots/order-process-3.png)



