import { createContext, useContext, useState, useEffect } from 'react';
import {
  CognitoUserPool,
  CognitoUser,
  AuthenticationDetails,
} from 'amazon-cognito-identity-js';

const pool = new CognitoUserPool({
  UserPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID,
  ClientId: import.meta.env.VITE_COGNITO_CLIENT_ID,
});

export const AuthContext = createContext(null);

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [idToken, setIdToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const cognitoUser = pool.getCurrentUser();
    if (!cognitoUser) { setLoading(false); return; }
    cognitoUser.getSession((err, session) => {
      if (err || !session.isValid()) { setLoading(false); return; }
      const payload = session.getIdToken().decodePayload();
      setIdToken(session.getIdToken().getJwtToken());
      setUser({
        username: payload['cognito:username'] || payload.email,
        email: payload.email,
        groups: payload['cognito:groups'] || [],
      });
      setLoading(false);
    });
  }, []);

  function signIn(username, password) {
    return new Promise((resolve, reject) => {
      const cognitoUser = new CognitoUser({ Username: username, Pool: pool });
      const authDetails = new AuthenticationDetails({ Username: username, Password: password });
      cognitoUser.authenticateUser(authDetails, {
        onSuccess(session) {
          const payload = session.getIdToken().decodePayload();
          const token = session.getIdToken().getJwtToken();
          const userData = {
            username: payload['cognito:username'] || payload.email,
            email: payload.email,
            groups: payload['cognito:groups'] || [],
          };
          setIdToken(token);
          setUser(userData);
          resolve(userData);
        },
        onFailure: reject,
        newPasswordRequired() { reject(new Error('NEW_PASSWORD_REQUIRED')); },
      });
    });
  }

  function signOut() {
    const cognitoUser = pool.getCurrentUser();
    if (cognitoUser) cognitoUser.signOut();
    setUser(null);
    setIdToken(null);
  }

  const isAdmin = user?.groups?.includes('admin') ?? false;

  return (
    <AuthContext.Provider value={{ user, idToken, loading, signIn, signOut, isAdmin }}>
      {children}
    </AuthContext.Provider>
  );
}
