import UserList from "../../components/UserList";
import UserForm from "../../components/UserForm";

export default function UsersPage() {
  return (
    <div>
      <h1>Users Page</h1>
      <UserForm />
      <UserList />
    </div>
  );
}