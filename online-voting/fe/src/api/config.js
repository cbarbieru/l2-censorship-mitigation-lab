const backEndBaseUrl = 'http://localhost:8080';
const config = {
    paths: {
        login: "/api/auth/signin",
        logout: "/api/auth/signout",
        register: "/api/auth/signup",
        isLoggedIn: "/api/user/loggedIn",
        accountDetails: "/api/user/accountDetails"
    },
    api: (path) => {
        return backEndBaseUrl + path;
    },
};

export default config;