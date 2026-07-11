if (sessionStorage.getItem('carnicos_session')) location.replace('app.html');
document.querySelector('#login-form').addEventListener('submit', (event) => {
  event.preventDefault();
  const user = document.querySelector('#username').value.trim();
  const password = document.querySelector('#password').value;
  if (user === 'admin' && password === 'admin123') {
    sessionStorage.setItem('carnicos_session', user);
    location.replace('app.html');
  } else document.querySelector('#login-error').textContent = 'Usuario o contraseña incorrectos.';
});
