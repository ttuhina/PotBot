const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const app = express();
app.use(express.json());

// MySQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', 
    database: 'restaurant_bot'
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
    } else {
        console.log('MySQL Connected');
    }
});

//API for Restaurant Discovery: Search for restaurants by cuisine, location or price range
//filters on basis of price, location and cuisine

app.get('/api/restaurants', (req, res) => {
    const { cuisine, price, location } = req.query;

    let query = 'SELECT r.id, r.name, AVG(re.rating) AS avg_rating ' +
    'FROM restaurants r ' +
    'LEFT JOIN reviews re ON r.id = re.restaurant_id ' +
    'WHERE 1=1 ';

    const queryParams = [];

    if (cuisine) {
      query += 'AND r.cuisine LIKE ? ';
      queryParams.push(`%${cuisine}%`);
    }

    if (price) {
      query += 'AND r.price = ? ';
      queryParams.push(price);
    }

    if (location) {
      query += 'AND r.location LIKE ? ';
      queryParams.push(`%${location}%`);
    }

    query += 'GROUP BY r.id, r.name';

    db.query(query, queryParams, (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        return res.status(500).json({ error: 'Error executing query' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Restaurant not found' });
      }

      const formattedResults = results.map(result => ({
        name: `${result.name} (${result.avg_rating ? result.avg_rating.toFixed(1) : 'N/A'})`
      }));

      res.json(formattedResults);
    });
});

//API for Customer reviews : view negative and positive customer reviews 
//filters reviews on basis of rating

app.get('/api/reviews/positive', (req, res) => {
  const { restaurantName } = req.query;

  const query = `
    SELECT r.name, rev.username, rev.review
    FROM restaurants r
    JOIN reviews rev ON r.id = rev.restaurant_id
    WHERE r.name LIKE ? AND rev.rating >= 3
    LIMIT 5
  `;
  
  db.query(query, [`%${restaurantName}%`], (err, results) => {
    if (err) {
      console.error('Error fetching positive reviews:', err);
      return res.status(500).json({ error: 'Error fetching positive reviews' });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'No positive reviews found for this restaurant' });
    }
    
    res.json({ restaurantName: results[0].name, reviews: results });
  });
});

  app.get('/api/reviews/negative', (req, res) => {
    const { restaurantName } = req.query;
    const query = `
      SELECT r.name, rev.username, rev.review
      FROM restaurants r
      JOIN reviews rev ON r.id = rev.restaurant_id
      WHERE r.name LIKE ? AND rev.rating < 3
      LIMIT 5
    `;
    db.query(query, [`%${restaurantName}%`], (err, results) => {
      if (err) {
        console.error('Error fetching negative reviews:', err);
        return res.status(500).json({ error: 'Error fetching negative reviews' });
      }
      if (results.length === 0) {
        return res.status(404).json({ error: 'No negative reviews found for this restaurant' });
      }
      res.json({ restaurantName: results[0].name, reviews: results });
    });
  });

//API for Restaurant description: view brief description of restaurant
//fethes description field from restaurants table
app.get('/api/restaurant/description', (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    const query = 'SELECT description FROM restaurants WHERE name = ?';
    db.query(query, [name], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ error: 'Error executing query' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        res.json({ description: results[0].description });
    });
});

// API for Menu : view menu images for restaurants. in final version, the different menu images for each
//restaurant can be added to the database. this method is preffered over text-based menu for visual appeal of user
//fetches the menu field in restaurants table.
app.get('/api/restaurant/menu', (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    const query = 'SELECT menu FROM restaurants WHERE name = ?';
    db.query(query, [name], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ error: 'Error executing query' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const menuImageUrl = results[0].menu;
        console.log(`Fetched menu URL for restaurant "${name}":`, menuImageUrl);

        if (!menuImageUrl) {
            return res.status(404).json({ error: 'Menu not found for this restaurant' });
        }

        // Check if the menu URL is a valid URL 
        const urlPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
        if (!urlPattern.test(menuImageUrl)) {
            return res.status(400).json({ error: 'Invalid menu URL format' });
        }

        res.json({ menu: menuImageUrl });
    });
});

//API for Reservation Management: Make reservations for your desired date and time, specifying any special requests
//adds user's reservation details to the reservations table
//also fetches available tables in the tables table
app.post('/api/reservations', (req, res) => {
  const { restaurantName, userName, reservationDate, reservationTime, specialRequests, numberOfPeople } = req.body;
  
  db.query('SELECT id FROM restaurants WHERE name = ?', [restaurantName], (err, results) => {
    if (err) {
      console.error('Error getting restaurant ID:', err);
      return res.status(500).json({ error: 'Error getting restaurant ID' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }
    const restaurantId = results[0].id;

    db.query(
      'SELECT id, table_number FROM tables WHERE restaurant_id = ? AND capacity >= ? AND availability = 1 AND id NOT IN (SELECT table_number FROM reservations WHERE restaurant_id = ? AND reservation_date = ? AND reservation_time = ?) LIMIT 1',
      [restaurantId, numberOfPeople, restaurantId, reservationDate, reservationTime],
      (err, tables) => {
        if (err) {
          console.error('Error checking available tables:', err);
          return res.status(500).json({ error: 'Error checking available tables' });
        }
        if (tables.length === 0) {
          return res.status(400).json({ error: 'No tables available for this party size at the requested time' });
        }

        const { id: tableId, table_number: tableNumber } = tables[0];

        db.query(
          'INSERT INTO reservations (restaurant_id, table_number, username, reservation_date, reservation_time, number_of_people, special_requests) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [restaurantId, tableNumber, userName, reservationDate, reservationTime, numberOfPeople, specialRequests],
          (err, result) => {
            if (err) {
              console.error('Error creating reservation:', err);
              return res.status(500).json({ error: 'Error creating reservation' });
            }
            
            // Update table availability
            db.query('UPDATE tables SET availability = 0 WHERE id = ?', [tableId], (err) => {
              if (err) {
                console.error('Error updating table availability:', err);
              }
              
              res.status(201).json({ 
                message: `Your reservation has been made for table number ${tableNumber}`,
                reservationId: result.insertId, 
                tableNumber: tableNumber 
              });
            });
          }
        );
      }
    );
  });
});

//API for reservation cancellation, or reservation process cancellation
//deletes the reservation from the reservations table and updates availability of table in tables table
app.post('/api/cancel-reservation', (req, res) => {
  const { tableNumber } = req.body;
  
  // gets reservation information
  db.query('SELECT reservation_id, restaurant_id FROM reservations WHERE table_number = ?', [tableNumber], (err, results) => {
    if (err) {
      console.error('Error getting reservation details:', err);
      return res.status(500).json({ error: 'Error cancelling reservation' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    
    const { id: reservationId, restaurant_id } = results[0];
    
    // Deletes reservation
    db.query('DELETE FROM reservations WHERE reservation_id = ?', [reservationId], (err, result) => {
      if (err) {
        console.error('Error cancelling reservation:', err);
        return res.status(500).json({ error: 'Error cancelling reservation' });
      }
      
      // Update table availability
      db.query('UPDATE tables SET availability = 1 WHERE restaurant_id = ? AND table_number = ?', [restaurant_id, tableNumber], (err) => {
        if (err) {
          console.error('Error updating table availability:', err);
        }
        
        res.json({ message: 'Reservation cancelled successfully' });
      });
    });
  });
});

// API to get restaurant ID by name
app.post('/api/id', (req, res) => {
    const { restaurant_name } = req.body;
    if (!restaurant_name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }
    const query = `SELECT id FROM restaurants WHERE name = ?`;
    db.query(query, [restaurant_name], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }
        res.json({ id: results[0].id });
    });
});

// API for Ordering Made Easy: Place orders for delivery or pickup directly through the bot, adding or removing items with ease
// adds the user's order details to the orders table
//calculates total price of order
app.post('/api/orders', (req, res) => {
  const { restaurant_id, username, order_type, order_details, total_price } = req.body;
  if (!restaurant_id || !username || !order_type || !order_details || total_price === undefined) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  const query = `
    INSERT INTO orders (restaurant_id, username, order_type, order_details, total_price, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
  `;
  db.query(query, [restaurant_id, username, order_type, JSON.stringify(order_details), total_price], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
    res.status(201).json({ message: 'Order created successfully', order_id: result.insertId });
  });
});

//Order Tracking: Receive real-time updates on the status of your order, from confirmation to delivery (or pickup notification)
//fetches the status field from orders table
app.get('/api/order-status/:orderId', (req, res) => {
  const orderId = req.params.orderId;
  const query = 'SELECT status FROM orders WHERE order_id = ?';
  
  db.query(query, [orderId], (err, results) => {
    if (err) {
      console.error('Error fetching order status:', err);
      return res.status(500).json({ error: 'Error fetching order status' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json({ status: results[0].status });
  });
});

app.post('/api/update-order-status', (req, res) => {
  const { orderId, status } = req.body;
  const query = 'UPDATE orders SET status = ? WHERE order_id = ?';
  
  db.query(query, [status, orderId], (err, result) => {
    if (err) {
      console.error('Error updating order status:', err);
      return res.status(500).json({ error: 'Error updating order status' });
    }
    res.json({ message: 'Order status updated successfully' });
  });
});

//API for cancelling order or order process and deleting the order from the database
app.post('/api/cancel-order', (req, res) => {
  const { orderId } = req.body;
  const query = 'DELETE FROM orders WHERE order_id = ?';
  
  db.query(query, [orderId], (err, result) => {
    if (err) {
      console.error('Error cancelling order:', err);
      return res.status(500).json({ error: 'Error cancelling order' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json({ message: 'Order cancelled successfully' });
  });
});

//API to match user-entered menu items to database menu items during ordering process 

  app.post('/api/menu', (req, res) => {
    const { restaurant_id, items } = req.body;
    const query = 'SELECT item, price FROM menus WHERE restaurant_id = ? AND item IN (?)';
    db.query(query, [restaurant_id, items], (err, results) => {
      if (err) {
        console.error('Error fetching menu items:', err);
        return res.status(500).json({ error: 'Error fetching menu items' });
      }
      res.json(results);
    });
  });

//API for Payment Integration: Securely pay for your order using a connected payment method within the chat interface

app.post('/api/create-razorpay-order', (req, res) => {
  const { amount, currency, receipt, notes } = req.body;

  razorpay.orders.create({amount, currency, receipt, notes}, (err, order) => {
    if (err) {
      console.error('Error creating Razorpay order:', err);
      return res.status(500).json({ error: 'Error creating Razorpay order' });
    }
    res.json(order);
  });
});

// Verify Razorpay payment
app.post('/api/verify-razorpay-payment', (req, res) => {
  const { order_id, payment_id, signature } = req.body;
  
  const generated_signature = crypto
    .createHmac('sha256', 'YOUR_RAZORPAY_KEY_SECRET')
    .update(order_id + "|" + payment_id)
    .digest('hex');
  
  if (generated_signature === signature) {
    res.json({ verified: true });
  } else {
    res.status(400).json({ verified: false, error: 'Invalid signature' });
  }
});

// Update order status
app.post('/api/update-order', (req, res) => {
  const { orderId, status } = req.body;
  const query = 'UPDATE orders SET status = ? WHERE order_id = ?';
  db.query(query, [status, orderId], (err, result) => {
    if (err) {
      console.error('Error updating order status:', err);
      return res.status(500).json({ error: 'Error updating order status' });
    }
    res.json({ message: 'Order status updated successfully' });
  });
});

//API for recommendations
//fetches number of times a user has ordered from a restaurant
app.get('/api/recommendations', (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  const query = `
    SELECT r.id, r.name, r.cuisine, COUNT(*) as order_count
    FROM restaurants r
    JOIN orders o ON r.id = o.restaurant_id
    WHERE o.username = ?
    GROUP BY r.id, r.name, r.cuisine
    ORDER BY order_count DESC
    LIMIT 5
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching recommendations:', err);
      return res.status(500).json({ error: 'Error fetching recommendations' });
    }

    res.json(results);
  });
});

  // Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});