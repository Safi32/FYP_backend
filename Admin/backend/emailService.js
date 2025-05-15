const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'dineddeal@gmail.com', // ✅ Your Gmail
    pass: 'kxly nfsq pcpf xvzu', // ✅ Use an App Password (DO NOT use your real password)
  },
});

async function sendEmail(to, subject, text) {
  const mailOptions = {
    from: 'dineddeal@gmail.com',
    to,
    subject,
    text,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`✅ Email sent to ${to}`);
  } catch (error) {
    console.error(`❌ Error sending email: ${error.message}`);
  }
}

module.exports = { sendEmail };
