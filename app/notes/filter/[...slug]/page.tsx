import { Metadata } from 'next';
import { QueryClient, HydrationBoundary, dehydrate } from '@tanstack/react-query';
import { fetchNotesByTag } from '@/lib/actions';
import NotesClient from './Notes.client';

interface PageProps {
  params: Promise<{ slug: string[] }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const tag = slug[0];
  const title = tag === 'all' ? 'All Notes' : `Notes filtered by ${tag}`;

  return {
    title: `${title} | NoteHub`,
    description: `View and manage your ${tag === 'all' ? 'all' : tag} notes in NoteHub.`,
    openGraph: {
      title: `${title} | NoteHub`,
      description: `View and manage your ${tag === 'all' ? 'all' : tag} notes.`,
      url: `https://your-domain.vercel.app/notes/filter/${tag}`,
      images: [
        {
          url: 'https://ac.goit.global/fullstack/react/notehub-og-meta.jpg',
        },
      ],
    },
  };
}

export default async function FilteredNotesPage({ params }: PageProps) {
  const { slug } = await params;
  const tag = slug[0];
  const queryTag = tag === 'all' ? 'all' : tag;

  const queryClient = new QueryClient();

  try {
    await queryClient.prefetchQuery({
      queryKey: ['notes', queryTag, ''],
      queryFn: () =>
        fetchNotesByTag(queryTag === 'all' ? '' : queryTag),
    });
  } catch (error) {
    console.error('Prefetch notes failed:', error);
  }

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <NotesClient tag={queryTag} />
    </HydrationBoundary>
  );
}
