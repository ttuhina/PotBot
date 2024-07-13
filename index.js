const restify = require('restify');
const { BotFrameworkAdapter, ActivityHandler } = require('botbuilder');
const axios = require('axios');
const Razorpay = require('razorpay');
const crypto = require('crypto');

// in final version, we would need to sign up with razorpay under a business name, and add the given 
//credentials over here.

const razorpay = new Razorpay({
  key_id: 'YOUR_RAZORPAY_KEY_ID',
  key_secret: 'YOUR_RAZORPAY_KEY_SECRET'
});

const adapter = new BotFrameworkAdapter({
  appId: process.env.MicrosoftAppId || '',
  appPassword: process.env.MicrosoftAppPassword || ''
});

//bot logic

class MyBot extends ActivityHandler {
  constructor() {
    super();
    this.knownRestaurants = [];
    this.loadRestaurantNames();
    this.currentOrder = null;
    this.currentReservation = null;
    this.waitingForPaymentConfirmation = false;
    this.currentPayment = null;
    this.orderFinalized = false;
    this.onMembersAdded(async (context, next) => {
      const membersAdded = context.activity.membersAdded;
      for (const member of membersAdded) {
        if (member.id !== context.activity.recipient.id) {
          await context.sendActivity(`Hey, I'm PotBot! I can help you:`);
          await context.sendActivity(` Find restaurants:\n Use 'cuisine:', 'location:', or 'price:' followed by your preference. 
        \n  Example: "cuisine: Japanese price: affordable location: Vaishali Nagar"
        \n   (Currently serving: Vaishali Nagar, C Scheme, Malviya Nagar)`);
          await context.sendActivity(`View Menus:\n
            Simply say "menu" followed by the restaurant name.
        \n  Example: "menu Spice Route."`);
          await context.sendActivity(` Make reservations:\n Say 'reserve' or 'reservation' followed by the restaurant name. 
        \n  Example: "reserve Golden Dragon"`);     
          await context.sendActivity(` Place orders: \n Say 'order' followed by the restaurant name for pickup/delivery. 
        \n  Example: "order Sakura Sushi"`);
          await context.sendActivity(` Get restaurant information:
        \n- For description: Say "description" followed by the restaurant name.
            Example: "description Red Lantern"
        \n- For positive reviews: Say "positive reviews" followed by the restaurant name.
            Example: "positive reviews Pasta Fiesta"
        \n- For negative reviews: Say "negative reviews" followed by the restaurant name.
            Example: "negative reviews Burger Joint"`);
            await context.sendActivity(` Personalized Recommendations: Based on your past choices and preferences, 
              I can suggest relevant restaurants and dishes. `);
          await context.sendActivity(`How can I assist you today?`);

      }
      }
      await next();
    });
    
// This function handles incoming messages from the user and routes them based on the current state of conversation

this.onMessage(async (context, next) => {
  const text = context.activity.text.toLowerCase().trim();
  
  if (text.startsWith('cancel order')) {
      await this.cancelOrder(context, text);
  } else if (text.startsWith('cancel reservation')) {
      await this.cancelReservation(context, text);
  } else if (text === 'recommendations' || text === 'suggest restaurants') {
      await this.getPersonalizedRecommendations(context);
  } else if (this.waitingForPaymentConfirmation) {
      if (text === 'yes') {
          await this.initiatePayment(context);
          this.waitingForPaymentConfirmation = false;
      } else if (text === 'no') {
          await context.sendActivity('Order placed but not paid. You can pay later by saying "pay for order".');
          this.waitingForPaymentConfirmation = false;
      } else {
          await context.sendActivity('Please respond with Yes to proceed with payment, or No to pay later.');
      }
  } else if (this.currentPayment && this.currentPayment.pendingConfirmation) {
      await this.confirmPayment(context, text);
  } else if (text.startsWith('order')) {
      await this.handleOrder(context, text);
  } else if (this.currentOrder && !this.currentOrder.orderType) {
      await this.handleOrderType(context, text);
  } else if (this.currentOrder && !this.currentOrder.items.length) {
      await this.processOrderItems(context, text);
  } else if (this.currentOrder && this.currentOrder.items.length && !this.orderFinalized) {
      await this.confirmOrder(context, text);
  } else if (text === 'pay for order') {
      if (this.currentOrder && this.currentOrder.orderId) {
          await this.initiatePayment(context);
      } else {
          await context.sendActivity('You don\'t have any pending orders to pay for.');
      }
  } else if (this.currentReservation && this.currentReservation.pendingConfirmation) {
      await this.confirmReservation(context, text);
  } else if (this.currentReservation) {
      await this.processReservationDetails(context, text);
  } else if (text.includes('reserve') || text.includes('reservation')) {
      const restaurantName = this.findRestaurantName(text);
      if (restaurantName) {
          await this.handleReservation(context, restaurantName);
      } else {
          await context.sendActivity(`I'm sorry, I couldn't find a restaurant matching "${restaurantName}". Please check the name and try again. Here are the available restaurants: ${this.knownRestaurants.join(', ')}`);
      }
  } else if (text.startsWith('track order')) {
      const orderId = text.split(' ')[2]; 
      if (orderId) {
          await this.trackOrder(context, orderId);
      } else {
          await context.sendActivity('Please provide an order ID. For example: "track order 123"');
      }
  } else {
      const restaurantName = this.findRestaurantName(text);
      if (restaurantName) {
          await this.handleRestaurantQuery(context, text, restaurantName);
      } else {
          await this.processCriteria(context, text);
      }
  }

  await next();
});
}

// Restaurant Discovery: Search for restaurants by cuisine, location and price ranges

async processCriteria(context, text) {
  const cuisine = text.match(/cuisine:?\s*(\w+)/)?.[1] || '';
  const location = text.match(/location:?\s*(\w+)/)?.[1] || '';
  let price = text.match(/price:?\s*([\w\s]+)/)?.[1]?.trim() || '';

  const priceMapping = {
      affordable: 'affordable', inexpensive: 'affordable', cheap: 'affordable', low: 'affordable', $: 'affordable',
      moderate: 'moderate', average: 'moderate', normal: 'moderate', $$: 'moderate',
      expensive: 'expensive', pricey: 'expensive', high: 'expensive', $$$: 'expensive'
  };
  price = priceMapping[price] || price;

  if (cuisine || location || price) {
      try {
          const response = await axios.get(`http://localhost:3000/api/restaurants?cuisine=${cuisine}&location=${location}&price=${price}`);
          const restaurants = response.data;
          if (restaurants.length > 0) {
              let message = 'Here are some restaurants that match your criteria:';
              restaurants.forEach((restaurant, index) => {
                  message += `\n${index + 1}. ${restaurant.name}`;
              });
              message += '\n\nYou may ask for a menu, description, positive reviews, or negative reviews by writing those terms accompanied by the restaurant name! Let me know when you\'ve selected a restaurant to visit or order from.';
              await context.sendActivity(message);
          } else {
              await context.sendActivity('Sorry, no restaurants found matching your criteria.');
          }
      } catch (error) {
          console.error('Error fetching restaurants:', error);
          await context.sendActivity('Sorry, there was an error fetching restaurants.');
      }
  } else {
      await context.sendActivity('Please provide at least one criteria: Cuisine, Location, or Price.');
  }
}

//Handle queries about specific restaurants

  async handleRestaurantQuery(context, text, restaurantName) {
    const lowerText = text.toLowerCase();
    if (lowerText.includes('description')) {
        await this.sendRestaurantDescription(context, restaurantName);
    } else if (lowerText.includes('menu')) {
        await this.sendRestaurantMenu(context, restaurantName);
    } else if (lowerText.includes('positive review')) {
        await this.sendPositiveReviews(context, restaurantName);
    } else if (lowerText.includes('negative review')) {
        await this.sendNegativeReviews(context, restaurantName);
    } else {
        await context.sendActivity(`What would you like to know about ${restaurantName}? You can ask for the
           description, menu, positive reviews, or negative reviews.
        \n- For description: Say "description" followed by the restaurant name.
            Example: "description Red Lantern"
        \n- For positive reviews: Say "positive reviews" followed by the restaurant name.
            Example: "positive reviews Pasta Fiesta"
        \n- For negative reviews: Say "negative reviews" followed by the restaurant name.
            Example: "negative reviews Burger Joint"`);
    }
  }
  
  //Customer reviews : view negative and positive customer reviews 
  
  async sendPositiveReviews(context, restaurantName) {
    try {
      const encodedName = encodeURIComponent(restaurantName);
      const response = await axios.get(`http://localhost:3000/api/reviews/positive?restaurantName=${encodedName}`);
      const { reviews } = response.data;
      if (reviews && reviews.length > 0) {
        let message = `Positive reviews for ${restaurantName}:`;
        reviews.forEach((review, index) => {
          message += `\n${index + 1}. ${review.username} said: ${review.review}`;
        });
        await context.sendActivity(message);
      } else {
        await context.sendActivity(`No positive reviews found for ${restaurantName}.`);
      }
    } catch (error) {
      console.error('Error fetching positive reviews:', error);
      await context.sendActivity(`Sorry, I couldn't fetch positive reviews for ${restaurantName}.`);
    }
  }
  
  async sendNegativeReviews(context, restaurantName) {
    try {
      const encodedName = encodeURIComponent(restaurantName);
      const response = await axios.get(`http://localhost:3000/api/reviews/negative?restaurantName=${encodedName}`);
      const { reviews } = response.data;
      
      if (reviews && reviews.length > 0) {
        let message = `Negative reviews for ${restaurantName}:`;
        reviews.forEach((review, index) => {
          message += `\n${index + 1}. ${review.username} said: ${review.review}`;
        });
        await context.sendActivity(message);
      } else {
        await context.sendActivity(`No negative reviews found for ${restaurantName}.`);
      }
    } catch (error) {
      console.error('Error fetching negative reviews:', error);
      await context.sendActivity(`Sorry, I couldn't fetch negative reviews for ${restaurantName}.`);
    }
  }

//Restaurant description: view brief description of restaurant

  async sendRestaurantDescription(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/restaurant/description?name=${encodeURIComponent(restaurantName)}`);
      const description = response.data.description;
      await context.sendActivity(description ? `Description for ${restaurantName}: ${description}` : `Sorry, I couldn't find the description for ${restaurantName}.`);
    } catch (error) {
      console.error('Error fetching restaurant description:', error);
      await context.sendActivity(`Sorry, I couldn't find the description for ${restaurantName}.`);
    }
  }

// Menu : view menu images for restaurants. in final version, the different menu images for each
//restaurant can be added to the database. this method is preffered over text-based menu for visual appeal of user
  
  async sendRestaurantMenu(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/restaurant/menu?name=${encodeURIComponent(restaurantName)}`);
      const menuImageUrl = response.data.menu;
      if (menuImageUrl) {
        await context.sendActivity({
          type: 'message',
          text: `Here is the menu for ${restaurantName}:`,
          attachments: [{ contentType: 'image/jpeg', contentUrl: menuImageUrl, name: 'Menu' }]
        });
      } else {
        await context.sendActivity(`Sorry, I couldn't find the menu for ${restaurantName}.`);
      }
    }  catch (error) {
      console.error('Error fetching restaurant menu image:', error);
      if (error.response) {
        if (error.response.status === 404) {
          await context.sendActivity(`Sorry, I couldn't find a restaurant named ${restaurantName}.`);
        } else {
          await context.sendActivity(`Sorry, there was an error fetching the menu for ${restaurantName}. Please try again later.`);
        }
      } else {
        await context.sendActivity(`Sorry, there was a network error. Please try again later.`);
      }
    }
  }

//. Reservation Management: Make reservations for your desired date and time, specifying any special requests

//asks for reservation details
async handleReservation(context, restaurantName) {
  this.currentReservation = { restaurantName };
  await context.sendActivity(`Great! You want to make a reservation at ${restaurantName}. Let's get started.\n 
  You can stop the reservation process at any time, or cancel an existing reservation, by saying cancel reservation,
  followed by your table number. for example, "Cancel reservation 6."`);
  await context.sendActivity('Please provide the following details in order:\n' +
    '1. Name\n' +
    '2. Date (YYYY-MM-DD)\n' +
    '3. Time (HH:MM)\n' +
    '4. Special requests (if any, otherwise type "None")\n' +
    '5. Number of people\n\n' +
    'Example: John Doe, 2024-06-21, 19:00, Vegetarian preferences, 4');
}
//checks details entered by user
  async processReservationDetails(context, text) {
  console.log('Received reservation details:', text);
  const details = text.split(',').map(item => item.trim());
  console.log('Split details:', details);

  if (details.length !== 5) {
    console.log('Invalid number of details:', details.length);
    await context.sendActivity('Invalid input format. Please provide details in the correct format.');
    return;
  }

  const [userName, reservationDate, reservationTime, specialRequests, numberOfPeople] = details;

  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
  
  if (!dateRegex.test(reservationDate)) {
    console.log('Invalid date format:', reservationDate);
    await context.sendActivity('Invalid date format. Please use YYYY-MM-DD.');
    return;
  }

  if (!timeRegex.test(reservationTime)) {
    console.log('Invalid time format:', reservationTime);
    await context.sendActivity('Invalid time format. Please use HH:MM.');
    return;
  }

  this.currentReservation = {
    ...this.currentReservation,
    userName,
    reservationDate,
    reservationTime,
    specialRequests,
    numberOfPeople,
    pendingConfirmation: true 
  };

  console.log('Current reservation:', this.currentReservation);

  await context.sendActivity(
    `Let me confirm your reservation details:\n` +
    `Restaurant: ${this.currentReservation.restaurantName}\n` +
    `Name: ${this.currentReservation.userName}\n` +
    `Date: ${this.currentReservation.reservationDate}\n` +
    `Time: ${this.currentReservation.reservationTime}\n` +
    `Special Requests: ${this.currentReservation.specialRequests}\n\n` +
    `Number of People: ${this.currentReservation.numberOfPeople}\n` +
    `Is this correct? (Yes/No)`
  );
}
//confirms the reservation and adds details to the reservations table
async confirmReservation(context, confirmation) {
  if (confirmation.toLowerCase() === 'yes') {
    try {
      const response = await axios.post('http://localhost:3000/api/reservations', {
        restaurantName: this.currentReservation.restaurantName,
        userName: this.currentReservation.userName,
        reservationDate: this.currentReservation.reservationDate,
        reservationTime: this.currentReservation.reservationTime,
        specialRequests: this.currentReservation.specialRequests,
        numberOfPeople: this.currentReservation.numberOfPeople
      });

      if (response.data.tableNumber) {
        await context.sendActivity(`Your reservation has been made successfully! You have been assigned table 
          number ${response.data.tableNumber}. Is there any other way i can assist you?`);
      } else {
        await context.sendActivity('Sorry, there are no tables available for this party size at the moment.');
      }
    } catch (error) {
      console.error('Error making reservation:', error);
      await context.sendActivity('Sorry, there was an error making your reservation.');
    }
  } else {
    await context.sendActivity('No problem, reservation cancelled. To restart the process, say "reserve" or "reservation" followed by the restaurant name.');
  }
  this.currentReservation = null;
}

//cancellation of reservation or reservation process
async cancelReservation(context, text) {
  const tableNumber = text.split(' ')[2]; 
  if (!tableNumber) {
    await context.sendActivity('Please provide a table number. For example: "cancel reservation 5"');
    return;
  }

  try {
    const response = await axios.post('http://localhost:3000/api/cancel-reservation', { tableNumber });
    await context.sendActivity(response.data.message);
  } catch (error) {
    console.error('Error cancelling reservation:', error);
    if (error.response && error.response.status === 404) {
      await context.sendActivity('Reservation not found. Please check the table number and try again.');
    } else {
      await context.sendActivity('Sorry, there was an error cancelling your reservation. Please try again.');
    }
  }
  await context.sendActivity('How else may I assist you?');
}

// Ordering Made Easy: Place orders for delivery or pickup directly through the bot, adding or removing items with ease

  async handleOrder(context, text) {
    const restaurantName = text.replace(/^order\s*/i, '').trim();
    
    if (!restaurantName) {
      await context.sendActivity("Please provide a restaurant name. For example: 'order Pizza Palace'");
      return;
    }
  
    const lowerCaseRestaurantName = restaurantName.toLowerCase();
    
    const matchedRestaurant = this.knownRestaurants.find(name => 
      name.toLowerCase().includes(lowerCaseRestaurantName) || 
      lowerCaseRestaurantName.includes(name.toLowerCase())
    );
    
    if (matchedRestaurant) {
      this.currentOrder = { restaurantName: matchedRestaurant, items: [] };
      await context.sendActivity(`Great!  You can stop the order process at any time, or cancel an existing order,
         by saying cancel order followed by your order ID. For example, "Cancel order 6". 
    \nWould you like to order for delivery or pickup from ${matchedRestaurant}? (Please respond with 'Delivery' or 'Pickup')`);
    } else {
      await context.sendActivity(`I'm sorry, I couldn't find a restaurant matching "${restaurantName}". Please check the name and try again. Here are the available restaurants:
      ${this.knownRestaurants.join(', ')}`);
    }
  }

  // Handles the type of order - Delivery or Pickup
async handleOrderType(context, text) {
  const orderType = text.trim().toLowerCase();
  if (orderType !== 'delivery' && orderType !== 'pickup') {
      await context.sendActivity("Please specify either 'Delivery' or 'Pickup'.");
      return;
  }

  if (!this.currentOrder) {
      this.currentOrder = {};
  }
  this.currentOrder.orderType = orderType;
  await context.sendActivity(`Great! What would you like to order from ${this.currentOrder.restaurantName}? Please list your items separated by commas. For example: "Chicken Tikka Masala, Naan Bread, Mango Lassi"`);
}

loadRestaurantNames() {
  this.knownRestaurants = [
    'Golden Dragon', 'Red Lantern', 'Dragons Breath', 'Casa Bonita', 'El Toro',
    'Pablos Cantina', 'Bangkok Street', 'Lotus Thai', 'Siam Sizzler', 'Maharajas Delight',
    'Spice Route', 'Nawabs Court', 'Pasta Fiesta', 'Bella Italia', 'Tuscan Table',
    'Sakura Sushi', 'Tokyo Dine', 'Zen Garden', 'Olive Tree', 'The Greek House',
    'Byzantine', 'Le Bistro', 'Cafe Paris', 'Chateau Noir', 'Burger Joint',
    'Diner Dash', 'Steakhouse 55'
];
}

findRestaurantName(input) {
  for (const name of this.knownRestaurants) {
      if (input.toLowerCase().includes(name.toLowerCase())) {
          return name;
      }
  }
  return null;
}

// Process the items the user wants to order
async processOrderItems(context, text) {
  const items = text.split(',').map(item => item.trim()).filter(item => item !== '');
  
  if (items.length === 0) {
    await context.sendActivity("Your order seems to be empty. Please provide at least one item.");
    return;
  }

  if (!this.currentOrder) {
    await context.sendActivity("I'm sorry, but I don't have an active order to process. Please start by saying 'order [restaurant name]'.");
    return;
  }

  try {
    const restaurantIdResponse = await axios.post('http://localhost:3000/api/id', { restaurant_name: this.currentOrder.restaurantName });
    const restaurantId = restaurantIdResponse.data.id;
    const menuItemsResponse = await axios.post('http://localhost:3000/api/menu', { 
      restaurant_id: restaurantId, 
      items: items 
    });
    const menuItems = menuItemsResponse.data;

    if (menuItems.length === 0) {
      throw new Error("No menu items found for your order. Please check the items and re start the ordering process by saying 'order', followed by the restaurant name.");
    }

    this.currentOrder.items = menuItems;
    this.currentOrder.restaurantId = restaurantId;

    await this.displayOrderSummary(context);
  } catch (error) {
    console.error('Error processing order:', error);
    let errorMessage = 'Sorry, there was an error processing your order. ';
    if (error.response) {
      errorMessage += `Server responded with: ${error.response.status} - ${error.response.data.error}`;
    } else if (error.request) {
      errorMessage += 'No response received from the server. Please check your internet connection.';
    } else {
      errorMessage += error.message;
    }
    errorMessage += '\nPlease try again by saying "order [restaurant name]".';
    await context.sendActivity(errorMessage);
    this.currentOrder = null; 
  }
}
// Display the order summary to the user
async displayOrderSummary(context) {
  let totalPrice = 0;
  let orderSummary = 'Here\'s a summary of your order:\n';

  for (const item of this.currentOrder.items) {
    orderSummary += `${item.item}: Rs. ${item.price.toFixed(2)}\n`;
    totalPrice += item.price;
  }

  orderSummary += `\nTotal price: Rs.${totalPrice.toFixed(2)}`;
  orderSummary += '\n\nTo add an item, say "add {item name}". To remove an item, say "remove {item name}".';
  orderSummary += '\nTo confirm the order, say "Yes". To cancel, say "No".';

  this.currentOrder.totalPrice = totalPrice;

  await context.sendActivity(orderSummary);
}
// Confirm the order, handle adding/removing items or finalizing the order
async confirmOrder(context, text) {
  const lowerText = text.toLowerCase().trim();

  if (lowerText.startsWith('add ')) {
    await this.addItem(context, lowerText.substring(4));
  } else if (lowerText.startsWith('remove ')) {
    await this.removeItem(context, lowerText.substring(7));
  } else if (lowerText === 'yes' || lowerText === 'no') {
    await this.finalizeOrder(context, lowerText);
  } else {
    await context.sendActivity('Please respond with "Yes" to confirm, "No" to cancel, "add {item}" to add an item, or "remove {item}" to remove an item.');
  }
}
//adding items
async addItem(context, itemName) {
  try {
    const menuItemResponse = await axios.post('http://localhost:3000/api/menu', { 
      restaurant_id: this.currentOrder.restaurantId, 
      items: [itemName] 
    });
    const newItem = menuItemResponse.data[0];

    if (newItem) {
      this.currentOrder.items.push(newItem);
      await context.sendActivity(`Added ${newItem.item} to your order.`);
    } else {
      await context.sendActivity(`Sorry, I couldn't find "${itemName}" on the menu.`);
    }

    await this.displayOrderSummary(context);
  } catch (error) {
    console.error('Error adding item:', error);
    await context.sendActivity('Sorry, there was an error adding the item to your order.');
  }
}
//removing items
async removeItem(context, itemName) {
  const index = this.currentOrder.items.findIndex(item => item.item.toLowerCase() === itemName.toLowerCase());
  if (index !== -1) {
    const removedItem = this.currentOrder.items.splice(index, 1)[0];
    await context.sendActivity(`Removed ${removedItem.item} from your order.`);
  } else {
    await context.sendActivity(`Sorry, I couldn't find "${itemName}" in your order.`);
  }

  await this.displayOrderSummary(context);
}

// Finalize the order based on user's confirmation
async finalizeOrder(context, confirmation) {
  if (confirmation.toLowerCase() === 'yes') {
    try {
      const orderData = {
        restaurant_id: this.currentOrder.restaurantId,
        username: context.activity.from.name,
        order_type: this.currentOrder.orderType,
        order_details: JSON.stringify(this.currentOrder.items),
        total_price: this.currentOrder.totalPrice,
        status: 'confirmed' 
      };

      const response = await axios.post('http://localhost:3000/api/orders', orderData);
      this.currentOrder.orderId = response.data.order_id;

      await context.sendActivity(`Your order has been confirmed! Order ID: ${response.data.order_id}.
      \n You can track your order status anytime by saying "track order ${response.data.order_id}"`);
      await context.sendActivity(`The total amount for your order is Rs. ${this.currentOrder.totalPrice.toFixed(2)}`);
      await context.sendActivity("Would you like to proceed with the payment? (Yes/No)");

      this.orderFinalized = true;
      this.waitingForPaymentConfirmation = true;

    } catch (error) {
      console.error('Error confirming order:', error);
      await context.sendActivity('Sorry, there was an error placing your order. Please try again.');
      this.currentOrder = null;
    }
  } else {
    await context.sendActivity('Order cancelled. If you\'d like to start over, just say "order [restaurant name]".');
    this.currentOrder = null;
    this.orderFinalized = false;
  }

}
//cancellation of order or order process
async cancelOrder(context, text) {
  const orderId = text.split(' ')[2]; 
  if (!orderId) {
    await context.sendActivity('Please provide an order ID. For example: "cancel order 123"');
    return;
  }

  try {
    const response = await axios.post('http://localhost:3000/api/cancel-order', { orderId });
    await context.sendActivity(response.data.message);
  } catch (error) {
    console.error('Error cancelling order:', error);
    if (error.response && error.response.status === 404) {
      await context.sendActivity('Order not found. Please check the order ID and try again.');
    } else {
      await context.sendActivity('Sorry, there was an error cancelling your order. Please try again.');
    }
  }
  await context.sendActivity('How else may I assist you?');
}

//Payment Integration: Securely pay for your order using a connected payment method within the chat interface

async initiatePayment(context) {
  try {
    const response = await axios.post('http://localhost:3000/api/create-razorpay-order', {
      amount: this.currentOrder.totalPrice * 100, // Razorpay expects amount in paise
      currency: 'INR',
      receipt: `order_${this.currentOrder.orderId}`,
      notes: {
        orderDetails: JSON.stringify(this.currentOrder)
      }
    });

    this.currentPayment = {
      orderId: response.data.id,
      amount: response.data.amount,
      pendingConfirmation: true
    };

    await context.sendActivity(`Please complete the payment of Rs. ${this.currentOrder.totalPrice.toFixed(2)} using this link: https://rzp.io/i/${response.data.id}`);
    await context.sendActivity("Once you've completed the payment, please type 'confirm payment' to verify and complete your order.");

  } catch (error) {
    console.error('Error creating Razorpay order:', error);
    await context.sendActivity('Sorry, there was an error processing your payment. Please try again later.');
  }
}

async confirmPayment(context, text) {
  if (text.toLowerCase() === 'confirm payment') {
    await context.sendActivity("Great! I'm verifying your payment now.");

    try {

      // In the final version, we would need to verify the payment with Razorpay here.
      // For this example, we'll assume the payment is successful.

      // Updating database to mark the order as paid
      await axios.post('http://localhost:3000/api/update-order', {
        orderId: this.currentOrder.orderId,
        status: 'paid'
      });

      await context.sendActivity("Payment confirmed! Your order has been placed and paid for. Thank you for your purchase!");
      this.currentOrder = null;
      this.currentPayment = null;
    } catch (error) {
      console.error('Error confirming payment:', error);
      await context.sendActivity('Sorry, there was an error confirming your payment. Please contact customer support.');
    }
  } else {
    await context.sendActivity("I didn't understand that. If you've completed the payment, please type 'confirm payment'.");
  }
}

//Order Tracking: Receive real-time updates on the status of your order, from confirmation to delivery (or pickup notification)

async trackOrder(context, orderId) {
  try {
    const response = await axios.get(`http://localhost:3000/api/order-status/${orderId}`);
    const status = response.data.status;
    
    let statusMessage;
    switch(status) {
      case 'pending':
        statusMessage = "Your order has been received and is pending confirmation.";
        break;
      case 'confirmed':
        statusMessage = "Your order has been confirmed and will be prepared soon.";
        break;
      case 'preparing':
        statusMessage = "Your order is currently being prepared.";
        break;
      case 'ready_for_pickup':
        statusMessage = "Your order is ready for pickup!";
        break;
      case 'out_for_delivery':
        statusMessage = "Your order is out for delivery.";
        break;
      case 'delivered':
        statusMessage = "Your order has been delivered. Enjoy your meal!";
        break;
      case 'completed':
        statusMessage = "Your order has been completed. Thank you for your business!";
        break;
      default:
        statusMessage = "Unable to retrieve order status.";
    }
    
    await context.sendActivity(statusMessage);
  } catch (error) {
    console.error('Error tracking order:', error);
    await context.sendActivity('Sorry, there was an error tracking your order. Please try again later.');
  }
}

// Personalized Recommendations: Based on your past choices and preferences, the bot can suggest relevant restaurants and dishes

async getPersonalizedRecommendations(context) {
  const userId = context.activity.from.id;

  try {
    const response = await axios.get(`http://localhost:3000/api/recommendations?userId=${userId}`);
    const recommendations = response.data;

    if (recommendations.length > 0) {
      let message = "Based on your past orders, here are some recommendations:";
      recommendations.forEach((restaurant, index) => {
        message += `\n${index + 1}. ${restaurant.name} (${restaurant.cuisine})`;
      });
      await context.sendActivity(message);
    } else {
      await context.sendActivity("I don't have enough data to make personalized recommendations yet. Try ordering from a few restaurants first!");
    }
  } catch (error) {
    console.error('Error getting recommendations:', error);
    await context.sendActivity('Sorry, there was an error fetching recommendations. Please try again later.');
  }
}

}

module.exports.MyBot = MyBot;
const bot = new MyBot();
const server = restify.createServer();
server.use(restify.plugins.bodyParser());
server.post('/api/messages', async (req, res) => {
  try {
    await adapter.processActivity(req, res, async (context) => {
      await bot.run(context);
    });
  } catch (error) {
    console.error('Error processing request:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Start the server

server.listen(process.env.PORT || 3978, () => {
  console.log(`Server running at http://localhost:${process.env.PORT || 3978}`);
});