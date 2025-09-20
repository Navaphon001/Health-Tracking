const https = require('https');

// Get token from environment variable or command line argument
const token = process.env.OPENROUTER_TOKEN || process.argv[2];

if (!token) {
  console.error('Error: Please provide your OpenRouter token');
  console.error('Usage: node check-credit.js <token>');
  console.error('Or set OPENROUTER_TOKEN environment variable');
  process.exit(1);
}

const options = {
  hostname: 'openrouter.ai',
  path: '/api/v1/key',
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`
  }
};

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      
      if (response.data) {
        console.log('OpenRouter API Key Info:');
        console.log(`Limit: ${response.data.limit}`);
        console.log(`Usage: ${response.data.usage}`);
      } else {
        console.error('Error:', data);
      }
    } catch (error) {
      console.error('Error parsing response:', error.message);
      console.error('Raw response:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('Request error:', error.message);
});

req.end();