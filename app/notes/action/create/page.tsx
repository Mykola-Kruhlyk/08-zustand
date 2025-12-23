import type { Metadata } from 'next';
import NoteForm from '@/components/NoteForm/NoteForm';

export const metadata: Metadata = {
  title: 'Create Note | NoteHub',
  description: 'Create a new note in NoteHub',
  openGraph: {
    title: 'Create Note | NoteHub',
    description: 'Create a new note in NoteHub',
    url: 'https://your-domain.vercel.app/notes/action/create',
    images: [
      {
        url: 'https://ac.goit.global/fullstack/react/notehub-og-meta.jpg',
      },
    ],
  },
};

export default function CreateNotePage() {
  return (
    <main>
      <h1>Create note</h1>
      <NoteForm />
    </main>
  );
}
